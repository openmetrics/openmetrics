namespace :doc do
  desc 'Generate Entity Relationship Diagram'
  task :erd do
    # system graph
    system 'erd --orientation=horizontal --title="Openmetrics Systems and Services" --only="System,Service,RunningService,CollectdService,DnsService,HttpService,NtpService,OpenmetricsAgentService,OpenmetricsService,SshService" --inheritance --filetype=dot --attributes=foreign_keys,content,inheritance'
    system "dot -Tpng erd.dot > doc/systems.png"
    File.delete('erd.dot')

    # test plan graph
    system 'erd --title="Openmetrics Webtests" --only="TestPlan,TestPlanItem,TestItem,TestItemType,TestCase,TestScript,TestExecution,TestExecutionResult" --inheritance --filetype=dot --attributes=foreign_keys,content,inheritance'
    system "dot -Tpng erd.dot > doc/webtests.png"
    File.delete('erd.dot')
  end
end