require 'sidekiq/scheduler'
Sidekiq.schedule = YAML.load_file(File.expand_path("../../../config/schedules.yml",__FILE__))