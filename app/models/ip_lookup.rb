class IpLookup < ActiveRecord::Base

  belongs_to :user
  has_one :ip_lookup_result

  # try to perform async, otherwise fail with meaningful status
  # use update_column here to bypass callbacks (were already within transaction here due to after_commit callback)
  include Executable
  def schedule_execution()
    begin
      update_column :status, 5 #init with 'none' state, as scheduling may fail
      update_column :job_id, IpLookupWorker.perform_async(self.id)
      update_column :status, EXECUTION_STATUS.key('scheduled')
      logger.info "IpLookup scheduled for execution (jid: #{self.job_id})."
    rescue Exception => e
      # job scheduling failed
      logger.error "Failed to schedule IpLookup due to exception #{e.message}"
    end
  end
  # create associated TestExecutionResult for latter processing
  def create_result()
    IpLookupResult.create!(ip_lookup: self)
  end

  # TODO improve for ip adresses, hostname and cidr notation
  validates :target, presence: true, :length => {:minimum => 3}
end
