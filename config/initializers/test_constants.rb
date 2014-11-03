# indicates processing status for TestExecution, IpLookup and TestExecutionItem
EXECUTION_STATUS = {
   5 => 'none',
  10 => 'scheduled',
  20 => 'prepared',
  30 => 'started',
  40 => 'finished'
}

# used as text results
QUALITY_STATUS = {
  0 => 'passed',
  5 => 'defective',
  10 => 'failed'
}

SEVERITIES = {
    5 => 'informational',
    10 => 'warning',
    15 => 'critical',
    20 => 'fatal'
}


EXECUTION_TMPDIR="#{Rails.root}/tmp/test_executions"
