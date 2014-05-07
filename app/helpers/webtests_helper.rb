module WebtestsHelper

  # print bootstrap button indicating processing status ('Running', 'Success', 'Fail')
  def test_execution_status(test_execution)
    def is_scheduled_or_prepared?(te)
      te.status == TEST_EXECUTION_STATUS.key('scheduled') or te.status == TEST_EXECUTION_STATUS.key('prepared')
    end
    def is_finished?(te)
      te.status == TEST_EXECUTION_STATUS.key('finished')
    end
    def is_running?(te)
      te.test_execution_result.exitstatus.nil? and self.is_scheduled_or_prepared?(te)
    end

    capture do
      # TestExecution is scheduled or prepared and exitstatus not yet set: running
      if is_running?(test_execution)
          concat '<button class="btn btn-info btn-lg btn-block"><i class="fa fa-spinner fa-spin"></i> Running</button>'.html_safe
      else
        if is_finished?(test_execution)
           # TestExecution is finished and exitstatus equals 0: success
           if test_execution.test_execution_result.exitstatus == 0
              concat '<button class="btn btn-success btn-lg btn-block"><i class="fa fa-thumbs-up"></i> Success</button>'.html_safe
           # TestExecution is finished and exitstatus is not 0: failure
           else
              concat '<button class="btn btn-danger btn-lg btn-block"><i class="fa fa-frown-o"></i> Failure</button>'.html_safe
           end
        end
        ## TestExecution not ran yet or partly failed
        #if !test_execution.exitstatus.nil? and is_scheduled_or_prepared?(test_execution)
        #  concat '<button class="btn btn-default btn-warning pull-right"> <i class="fa fa-spinner fa-meh-o"></i>Unknown</button>'
        #end
      end
    end
  end

end
