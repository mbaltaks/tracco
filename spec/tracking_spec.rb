require 'spec_helper'

require_relative '../lib/trello_authorize'
require_relative '../lib/tracking'
require_relative '../lib/trello_tracker'

describe Tracking do

  TIME_MEASUREMENTS = {
    hours:    'h',
    days:     'd',
    giorni:   'g',
    pomodori: 'p'
  }

  describe "#estimate?" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }) }

    it "is false when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate?.should be_false
    end

    TIME_MEASUREMENTS.each_key do |time_measurement|
      it "is true when the notification contains an estimate in #{time_measurement}" do
        Tracking.new(create_estimate(time_measurement)).estimate?.should be_true
      end
    end

  end

  describe "#estimate" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }) }

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate.should be_nil
    end

    it "is the hour-based effort when the notification contains an estimate in hours" do
      estimate_in_hours = stub(data: { 'text' => "@trackinguser [2h]" })
      Tracking.new(estimate_in_hours).estimate.should == 2
    end
  
    it "converts the effort in hours when the notification contains an estimate in days" do
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5d]" })).estimate.should == 8+4
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5g]" })).estimate.should == 8+4
    end

    it "converts the effort in hours when the notification contains an estimate in pomodori" do
      estimate_in_hours = stub(data: { 'text' => "@trackinguser [10p]" })
      Tracking.new(estimate_in_hours).estimate.should == 5
    end

  end

  def create_estimate(time_measurement)
    stub(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" })
  end
end
