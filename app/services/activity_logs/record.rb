class ActivityLogs::Record
  def self.call(action:, actor: nil, subject: nil, metadata: {})
    ActivityLog.create!(action: action, actor: actor, subject: subject, metadata: metadata)
  end
end
