# frozen_string_literal: true

require 'sinatra/base'
require 'slack-ruby-client'
require 'pry'

# This class contains all of the webserver logic for
# processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post Event data to.
  post '/events' do
    # Extract the Event payload from the request and parse the JSON
    request_data = JSON.parse(request.body.read)
    # Check the verification token provided with the request to
    # make sure it matches the verification token in
    # your app's setting to confirm that the request came from Slack.
    unless SLACK_CONFIG[:slack_verification_token] == request_data['token']
      halt 403, "Invalid verification token received: #{request_data['token']}"
    end

    case request_data['type']
    when 'url_verification'
      request_data['challenge']

    when 'event_callback'
      team_id = request_data['team_id']
      event_data = request_data['event']

      # Events have a "type" attribute included in their payload, allowing you
      # to handle different
      # Event payloads as needed.
      case event_data['type']
        # Other event types
        # team_join
        # reaction_added
        # pin_added
      when 'message'
        # Event handler for messages, including Share Message actions
        Events.message(team_id, event_data)
      else
        # In the event we receive an event we didn't expect, we'll log it
        # and move on.
        puts "Unexpected event:\n"
        puts JSON.pretty_generate(request_data)
      end
      # Return HTTP status code 200 so Slack knows we've received the Event
      status 200
    end
  end
end

# This class contains all of the Event handling logic.
class Events
  # You may notice that user and channel IDs may be found in
  # different places depending on the type of event we're receiving.

  def self.message(_team_id, event_data)
    # This is where our `message` event handlers go:
    # event_data sample:
    # {"type"=>"message",
    #  "user"=>"",
    #  "text"=>"test of the smileys :grin:",
    #  "ts"=>"",
    #  "channel"=>"",
    #  "event_ts"=>""}
    if event_data['text'].include?('geboekt') &&
       event_data['channel'] == SLACK_CONFIG[:slack_channel_id]
      %x(`play cash.wav`)
    end
  end
end
