require 'spec_helper'
require 'date'

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
        tracking_estimate = Tracking.new(create_estimate(time_measurement))

        tracking_estimate.estimate?.should be_true
        tracking_estimate.effort?.should be_false
      end
    end

  end

  describe "#estimate" do
    # example:
    #<Trello::Notification:0x007fbb9bd24c00
    # @attributes=
    # { :id=>"508d9e46bd57cd254c004160", :unread=>false, :type=>"mentionedOnCard", :date=>"2012-10-28T21:06:14.801Z",
    #   :data=>{"text"=>"@trackinguser [8h]", "card"=>{"name"=>"Portale - Aggiornare mappe", "idShort"=>321, "id"=>"508a6c7ea35182ae350046a6"}, "board"=>{"name"=>"Iterazione settimanale", "id"=>"502514e6af0f584e241bf9ec"}},
    #   :member_creator_id=>"4e8dfc6ba3e58a2341198ded"
    # }>

    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).estimate.should be_nil
    end

    it "is the hour-based estimate when the notification contains an estimate in hours" do
      estimate_in_hours = stub(data: { 'text' => "@trackinguser [2h]" }, date: "2012-10-28T21:06:14.801Z")

      Tracking.new(estimate_in_hours).estimate.amount.should == 2

      #TODO extract in separate spec and extracting the Estimate class
      Tracking.new(estimate_in_hours).estimate.date.to_s.should == "2012-10-28 21:06:14 UTC"
    end

    it "converts the estimate in hours when the notification contains an estimate in days" do
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5d]" }).as_null_object).estimate.amount.should == 8+4
      Tracking.new(stub(data: { 'text' => "@trackinguser [1.5g]" }).as_null_object).estimate.amount.should == 8+4
    end

    it "converts the estimate in hours when the notification contains an estimate in pomodori" do
      estimate_in_hours = stub(data: { 'text' => "@trackinguser [10p]" }).as_null_object
      Tracking.new(estimate_in_hours).estimate.amount.should == 5
    end

  end

  describe "#effort?" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is false when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).effort?.should be_false
    end

    TIME_MEASUREMENTS.each_key do |time_measurement|
      it "is true when the notification contains an estimate in #{time_measurement}" do
        tracking_effort = Tracking.new(create_effort(time_measurement))

        tracking_effort.effort?.should be_true
        tracking_effort.estimate?.should be_false
      end
    end
  end

  describe "#effort" do
    let(:unrecognized_notification) { stub(data: { 'text' => '@trackinguser hi there!' }).as_null_object }

    it "is nil when the notification does not contain an estimate" do
      Tracking.new(unrecognized_notification).effort.should be_nil
    end

    it "is the hour-based effort when the notification contains an effort in hours" do
      effort_in_hours = stub(data: { 'text' => "@trackinguser +2h" }).as_null_object
      Tracking.new(effort_in_hours).effort.amount.should == 2
    end

    it "converts the effort in hours when the notification contains an effort in days" do
      Tracking.new(stub(data: { 'text' => "@trackinguser +1.5d" }).as_null_object).effort.amount.should == 8+4
      Tracking.new(stub(data: { 'text' => "@trackinguser +1.5g" }).as_null_object).effort.amount.should == 8+4
    end

    it "converts the effort in hours when the notification contains an effort in pomodori" do
      effort_in_hours = stub(data: { 'text' => "@trackinguser +10p" }).as_null_object
      Tracking.new(effort_in_hours).effort.amount.should == 5
    end
  end



  def create_estimate(time_measurement)
    stub(data: { 'text' => "@trackinguser [1.5#{TIME_MEASUREMENTS[time_measurement]}]" }).as_null_object
  end

  def create_effort(time_measurement)
    stub(data: { 'text' => "@trackinguser +4.5#{TIME_MEASUREMENTS[time_measurement]}]" }).as_null_object
  end

end