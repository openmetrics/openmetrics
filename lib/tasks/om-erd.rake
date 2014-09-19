namespace :doc do
  desc 'Generate Entity Relationship Diagram'
  task :erd do
    # anything
      system 'erd --title="Openmetrics" --inheritance --polymorphism --filetype=dot --attributes=foreign_keys,content'
    system "dot -Tpng erd.dot > doc/openmetrics.png"
    File.delete('erd.dot')

    # system graph
    system 'erd --title="Openmetrics Systems" --only="System,Metric,CollectdPlugin,RunningCollectdPlugin,Service,RunningService,CollectdService,DnsService,HttpService,NtpService,OpenmetricsAgentService,OpenmetricsService,SshService" --inheritance --filetype=dot --attributes=foreign_keys,content'
    system "dot -Tpng erd.dot > doc/systems.png"
    File.delete('erd.dot')

    # test plan graph
    system 'erd --title="Openmetrics Webtests" --only="TestPlan,TestPlanItem,TestItem,TestItemType,TestCase,TestScript,TestExecution,TestExecutionResult" --polymorphism --inheritance --filetype=dot --attributes=foreign_keys,content'
    system "dot -Tpng erd.dot > doc/webtests.png"
    File.delete('erd.dot')
  end
end