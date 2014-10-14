#require 'selenium-webdriver' #dunny anymore why this was included...
require 'open3'
require 'test/unit/assertions' # to test quality

class TestExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include WebtestAutomagick
  include Test::Unit::Assertions

  def perform(test_execution_id, test_plan_id)
    tp = TestPlan.find(test_plan_id)
    te = TestExecution.find(test_execution_id)

    # try preparation and execution of testplan
    te.update_attributes(started_at: Time.now)
    begin
      te_items = prepare(te, tp)
      te.update_attributes(status: EXECUTION_STATUS.key('prepared'))
      te_items.each do |tei|
        execute(tei[0], tei[1], tei[2]) # test_execution_item_id, filename, interpreter
        evaluate_quality(TestExecutionItem.find_by_id(tei[0]))
      end
    rescue Exception => e
      # job preparation or execution failed,
      logger.warn "preparation or execution of TestExecution##{te.id} thrown exception #{e.message}"
      logger.debug e.backtrace.inspect
    ensure
      # persist execution finished
      te.update_attributes(finished_at: Time.now)
    end
    # test execution finished
    te.update_attributes(status: EXECUTION_STATUS.key('finished'))

    # decide test_plan quality for any non-success status
    evaluate_quality(te)

    # ... and overall execution result
    evaluate_result(te)

    # TODO remove (delete) create executable?
  end

  # reads test plans test_items and generates executables of it (TestExecutionItem) depending on item format/markup
  # returns pairs of arrays (test_execution_item_id, filename, interpreter)
  def prepare(te, tp)
    ret = [] # return array

    # create execution directory
    Dir.mkdir(EXECUTION_TMPDIR) unless Dir.exist?(EXECUTION_TMPDIR)
    dir = "#{EXECUTION_TMPDIR}/#{te.id.to_s}"
    Dir.mkdir(dir) unless Dir.exist?(dir)

    create_runsh!(dir)

    items = tp.test_items
    items.each_with_index { |item, n|
      # executable header (shebang) and extension
      header = ''
      interpreter = ''
      case item.format
        when 'selenese'
          header = "#!/usr/bin/env ruby\n"
          interpreter = 'ruby'
        when 'bash'
          header = "#!/bin/bash\n"
          interpreter = 'bash'
        when 'ruby'
          header = "#!/usr/bin/env ruby\n"
          interpreter = 'ruby'
      end

      # create executable file and change pwd (ugly way w/ ruby core utils)
      filename = dir+"/#{n+1}_#{item.id}"

      # prepare (and convert) markup and format
      conversion_format = item.format
      start_browser = n+1 == 1 ? true : false # start browser in first item
      quit_browser = n+1 == items.count ? true : false # quit browser in last item
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            WebtestAutomagick::selenese_to_webdriver(item.markup, tp.base_url, start_browser, quit_browser)
                          else
                            item.markup # use item.markup by default
                          end

      # overwrite format for converted if needed
      if item.type == 'TestCase' && item.format == 'selenese'
        conversion_format = 'ruby' # format should be ruby
      end

      # append newline to make humans interacting via terminals happy
      executable_markup+="\n" unless executable_markup.ends_with? "\n"

      # file extension
      case conversion_format
        when 'ruby'
          extension = '.rb'
        when 'bash'
          extension = '.sh'
        else
          extension = ''
      end
      filename = "#{filename}#{extension}"

      # persist as TestExecutionItem
      te_item = TestExecutionItem.create!(
          markup: header+executable_markup,
          format: conversion_format,
          executable: filename,
          test_item_id: item.id,
          test_execution_id: te.id
      )


      # write executable file to filesystem
      File.open(filename, 'w') { |f|
        f.chmod(0755)
        f.write(header+executable_markup)
      }

      # add executable filename and interpreter to return array
      ret.push([te_item.id, filename, interpreter])

    }

    # create helper libs for TestCase's
    if items.where(type: 'TestCase', format: 'selenese').any?
      WebtestAutomagick::setup_execution_helper(dir)
    end

    # return array of test_execution_id, filename & interpreter
    return ret
  end

  def execute(te_item_id, executable, interpreter='bash')
    te_item = TestExecutionItem.find(te_item_id)
    if te_item.nil?
      logger.warn("Couldn't execute #{executable}")
    else

      # set working dir (passed to open3)
      working_dir = File.dirname(executable)
      in_dir = "#{working_dir}/in"
      out_dir = "#{working_dir}/out"

      # prepare environment
      env = ENV.clone
      if te_item.provides_input?
        env.store('OM_TEST', 'foobar')
        env.store('OM_RANDOM', rand(99999).to_s)
      end

      # if item needs input, load vars into environment most recent infile
      if te_item.requires_input?
        all_in_files = Dir.glob("#{in_dir}/*.env")
        in_file = all_in_files.sort.last
        unless in_file.nil?
          text = File.open(in_file).read
          text.each_line do |line|
            var_name = line.split('=')[0]
            var_value = line.split('=')[1]
            logger.debug("Store into environment: #{var_name}=#{var_value}")
            env.store(var_name, var_value)
          end
        else
          logger.warn("Can't satisfy Test Execution Items input requirement!")
        end
      end

      # if this item provides input, persist env's to filesytem (by a sourceable bash file)
      if te_item.provides_input?
        Dir.mkdir(in_dir) unless Dir.exist?(in_dir)
        bash_env = ""
        te_item.provided_input.each do |input|
          bash_env += "#{input[0]}=#{input[1]}\n"
        end
        File.open(in_dir+"/#{te_item_id}.env", 'w') {|f| f.write(bash_env) }
      end

      # run command, pass in environment
      te_item.update_attributes(started_at: Time.now, status: EXECUTION_STATUS.key("started"))
      stdout, stderr, exit_status = Open3.capture3(env, interpreter, executable, :chdir => working_dir)
      te_item.update_attributes(finished_at: Time.now, status: EXECUTION_STATUS.key("finished"))

      # persist status
      exitstatus = exit_status.exitstatus # numeric return code of command
      textstatus = exit_status.success? ? 'succeeded' : 'failed'
      stdout = nil if stdout.blank? # make sure this is nil if there are no stdout contents
      stderr = nil if stderr.blank? # make sure this is nil if there are no stderr contents

      logger.debug "Executed #{interpreter} #{executable}"
      logger.debug "STDOUT: #{stdout}"
      logger.debug "STDERR: #{stderr}"
      logger.info "TestExecutionItem##{te_item.id} (TestExecution##{te_item.test_execution_id}) returned with status: #{textstatus} (exitstatus #{exitstatus})"
      te_item.update_attributes(output: stdout, error: stderr, exitstatus: exitstatus)
    end
  end

end

def evaluate_quality(entity)
  #logger.debug "Received entity of #{entity.class.name} #{entity.inspect} to evaluation"

  # entity may be a TestExecution or a TestExecutionItem
  # therefore get matching criteria and prepare quality object for later use
  if entity.class.name == 'TestExecution'
    criteria = QualityCriterion.where(qualifiable_type: 'TestPlan', qualifiable_id: entity.test_plan.id)
    quality = Quality.new(entity_type: 'TestPlan', entity_id: entity.test_plan.id, test_execution_id: entity.id)
  elsif entity.class.name == 'TestExecutionItem'
    criteria = QualityCriterion.where(qualifiable_type: 'TestItem', qualifiable_id: entity.test_item.id)
    quality = Quality.new(entity_type: 'TestItem', entity_id: entity.test_item.id, test_execution_id: entity.test_execution.id)
  end

  if criteria.any?
    logger.info "#{entity.class.name}##{entity.id} evaluating Quality"
    criteria.each do |criterion|
      entity_quality = quality.dup
      entity_quality.update_attributes(quality_criterion: criterion)

      # resolve operator to minitest assert operator
      numeric_operator = false
      present_operator = false
      blank_operator = false
      matches_operator = false
      operator = case criterion.operator
                   when 'present'
                     present_operator = true
                   when 'blank'
                     blank_operator = true
                   when 'includes', 'matches'
                   when 'lt', '<', 'lessThan'
                     numeric_operator = true
                     '<'
                   when 'lte', '<=', 'lessThanEqual'
                     numeric_operator = true
                     '<='
                   when 'gt', '>', 'greaterThan'
                     numeric_operator = true
                     '>'
                   when 'gte', '>=', 'greaterThanEqual'
                     numeric_operator = true
                     '>='
                   when 'eq', '==', 'equalTo'
                     numeric_operator = true
                     '=='
                   else
                     criterion.operator
                 end

      entity_value = if entity.respond_to? criterion.attr
                       entity.send(criterion.attr)
                     else
                       logger.error "#{entity.class.name}##{entity.id} can't evaluate criterion attribute #{criterion.attr}"
                       nil
                     end

      # cast criterion value to float if it's numeric
      criterion_value = (numeric_operator and criterion.value.is_numeric?) ? criterion.value.to_f : criterion.value

      # check criterion asserts
      begin
        if numeric_operator
          assert_operator(entity_value, operator.to_sym, criterion_value)
        elsif present_operator
          assert_present(entity_value.present?)
        elsif blank_operator
          assert(entity_value.blank?)
        end
        entity_quality.update_attributes(status: QUALITY_STATUS.key('passed'))
      rescue Minitest::Assertion => e
        logger.info "#{entity.class.name}##{entity.id} #{entity_value} #{operator} #{criterion_value} isn't true, #{e.message}"
        entity_quality.update_attributes(status: QUALITY_STATUS.key('defective'), message: e.message)
      rescue Exception => e
        logger.warn "#{entity.class.name}##{entity.id} couldn't assert #{entity_value} #{operator} #{criterion_value}"
        entity_quality.update_attributes(status: QUALITY_STATUS.key('failed'), message: e.message)
      end
    end
  end

end


def evaluate_result(te)
  te_result = te.test_execution_result

  if te.quality.any?
    if te.quality.where('status = ?', 10).any?
      te_result.update_attributes(exitstatus: QUALITY_STATUS.key('failed'))
    elsif te.quality.where('status = ?', 5).any?
      te_result.update_attributes(exitstatus: QUALITY_STATUS.key('defective'))
    else
      te_result.update_attributes(exitstatus: QUALITY_STATUS.key('passed'))
    end
  end

  # if no quality result exists, use the 'newest' non-zero exitstatus TestExecutionItem to mark for overall result:
  failed = te.test_execution_items.where(['exitstatus > ?', 0]).order('id')
  te_result.update_attributes(exitstatus: failed.last.exitstatus) if failed.any? and te_result.exitstatus.nil?

  # mark result success if status not yet decided
  te_result.update_attributes(exitstatus: 0) if te_result.exitstatus.nil?
end

# places run.sh in directory
def create_runsh!(dir)
runsh = %Q[
#!/bin/bash
scripts=$( ls *_* )
for script in ${scripts[@]} ; do
	 ./${script}
done
]

  File.open(dir+'/run.sh', 'w') { |f|
    f.chmod(0755)
    f.write(runsh)
  }
end

