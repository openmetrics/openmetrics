module WebtestsHelper

  # print bootstrap button indicating processing status, see TEST_EXECUTION_STATUS constant in
  def test_execution_status(test_execution)
    capture do
      # not even scheduled, show unknown staus and link to admin area
      if test_execution.not_scheduled?
        concat '<button class="btn btn-warning btn-lg btn-block">Not scheduled</button>'.html_safe
        concat '<p class="text-muted">Maybe Sidekiq isn\'t operational? Please check Status within '.html_safe
        concat link_to 'Admin Area', admin_path
        concat '.</p>'.html_safe
      end

      # job scheduled, but not executed yet
      if test_execution.is_scheduled_and_not_executed?
        concat '<button class="btn btn-info btn-lg btn-block">Not yet executed</button>'.html_safe
      end

      # beyond scheduling
      if test_execution.is_running?
        concat '<button class="btn btn-info btn-lg btn-block"><i class="fa fa-spinner fa-spin"></i> Running</button>'.html_safe
      else
        if test_execution.is_finished?
          #  finished and exitstatus is nil: unknown
          if test_execution.test_execution_result.exitstatus.nil?
            concat '<button class="btn btn-warning btn-lg btn-block"> Unknown</button>'.html_safe
            concat '<p class="text-muted">Test preparation may have failed.</p>'.html_safe
          else
            # finished and exitstatus equals 0: success
            if test_execution.test_execution_result.exitstatus == 0
              concat '<button class="btn btn-success btn-lg btn-block"><i class="fa fa-thumbs-up"></i> Success</button>'.html_safe
            else
              # FIXME TestExecution is finished and exitstatus > 0: MUST be failed *sic*
              concat '<button class="btn btn-danger btn-lg btn-block"><i class="fa fa-frown-o"></i> Failure</button>'.html_safe
            end
          end
        end
      end
    end # end capture block
  end

end
