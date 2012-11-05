require 'trello'
require 'rainbow'
require 'set'

class TrelloTracker
  include TrelloConfiguration
  include TrelloAuthorize
  include Trello

  trap("SIGINT") { exit! }

  def initialize(custom_auth_params = {})
    auth_params = configuration["trello"].merge(custom_auth_params)
    init_trello(auth_params)
  end

  def cards
    @cards ||= Set.new
  end

  def track
    tracker.notifications.each do |notification|
      tracking = Tracking.new(notification)
      begin
        card = cards.find {|c| c.id == tracking.card.id } || tracking.card
        if tracking.estimate?
          card.estimates << tracking.estimate
        elsif tracking.effort?
          card.efforts << tracking.effort
        end
        cards << card unless cards.map(&:id).include?(card.id)
        puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)}\t on card '#{tracking.card.name.color(:yellow)}': #{tracking.send(:raw_tracking)}"
      rescue StandardError => e
        puts "skipping tracking: #{e.message}".color(:red)
      end
    end
    puts "Tracked #{cards.size} cards."
    cards.each do |c|
      puts "* #{c.name}. Estimates #{c.estimates.inspect}. Efforts: #{c.efforts.inspect}"
    end
  end

  def tracker
    @tracker ||= Member.find(tracker_username)
  end
end
