require 'spec_helper'

describe ResumeScheduledSubscriptions do

  before do
    subscriptions_catalog = double('subscriptions catalog')
    @to_resume = [a_paused_subscription, a_paused_subscription]
    allow(subscriptions_catalog).to receive(:ready_to_resume).and_return(@to_resume)

    @resume_subscriptions = ResumeScheduledSubscriptions.new(subscriptions_catalog)
  end

  it "resumes all subscriptions that are scheduled to be resumed today" do
    @resume_subscriptions.resume_subscriptions_due_for_today

    expect(@to_resume).to all have_attributes(state: "active")
  end

  it "uses the Subscription model to fetch scheduled subscriptions" do
    ResumeScheduledSubscriptions.execute

    expect(Spree::Subscription.all).to all have_attributes(state: "active")
    expect(Spree::Subscription.ready_to_resume).to be_empty
  end

  def a_paused_subscription
    subscrition = FactoryGirl.create(:subscription, state: :paused, resume_at: Time.now - 1.day)
    subscrition.save!
    subscrition
  end

end
