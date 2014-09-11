# indicates processing status for TestExecution, IpLookup and TestExecutionItem
EXECUTION_STATUS = {
   5 => 'none',
  10 => 'scheduled',
  20 => 'prepared',
  30 => 'started',
  40 => 'finished'
}

QUALITY_STATUS = {
  5 => 'pass',
  10 => 'defect',
  15 => 'fail'
}

SEVERITIES = {
    5 => 'informational',
    10 => 'warning',
    15 => 'critical',
    20 => 'fatal'
}
