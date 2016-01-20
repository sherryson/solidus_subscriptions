class ResumeScheduledSubscriptions

  def self.execute
    new(Spree::Subscription).resume_subscriptions_due_for_today
  end

  def initialize(subscriptions_catalog)
    @subscriptions_catalog = subscriptions_catalog
  end

  def resume_subscriptions_due_for_today
    to_resume = @subscriptions_catalog.ready_to_resume
    to_resume.each { |subscription| subscription.resume }
    to_resume
  end

end
