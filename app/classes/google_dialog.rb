# frozen_string_literal: true

# project_id = "Your Google Cloud project ID"
# session_id = "mysession"
# texts = ["hello", "book a meeting room"]
# language_code = "en-US"

# Sample Ruby code from Dialogflow documentation
# require "google/cloud/dialogflow"

# session_client = Google::Cloud::Dialogflow::Sessions.new
# session = session_client.class.session_path project_id, session_id
# puts "Session path: #{session}"

# texts.each do |text|
#   query_input = { text: { text: text, language_code: language_code } }
#   response = session_client.detect_intent session, query_input
#   query_result = response.query_result

#   puts "Query text:        #{query_result.query_text}"
#   puts "Intent detected:   #{query_result.intent.display_name}"
#   puts "Intent confidence: #{query_result.intent_detection_confidence}"
#   puts "Fulfillment text:  #{query_result.fulfillment_text}\n"
# end

# require "google/cloud/dialogflow"
# require 'benchmark'

class GoogleDialog
  attr_accessor :state, :query, :session_id, :session_client, :project_id, :language_code
  def initialize(state, query, session_id)
    @state = state
    @query = query
    @session_id = session_id
    @session_client = Google::Cloud::Dialogflow::Sessions.new
    @project_id = Rails.application.secrets.dialogflow_project_id
    @language_code = 'ja'
  end

  # Query Dialogflow using the Ruby gem
  def query_dialogflow
    session = return_new_session
    @res = send_query_to_dialogflow(session)
    create_json_to_send(parse_fulfillment_text(@res['fulfillmentText']))
  end

  def parse_fulfillment_text(text)
    # <Benchmark::Tms:0x00007fcbd687c1d0 @label="for Nokogiri:", @real=54.961159999947995, @cstime=0.0, @cutime=0.0, @stime=0.04752600000000001, @utime=54.903189, @total=54.950714999999995>
    # <Benchmark::Tms:0x00007fcbd68bf3b8 @label="for String.include?:", @real=0.13650100002996624, @cstime=0.0, @cutime=0.0, @stime=4.999999999999449e-05, @utime=0.13644500000000903, @total=0.13649500000000903>
    # It is safe to say that String.include? is like a billion times faster than Nokogiri, so we'll check for the presence of the tag before parsing
    if text.include?('<speak>')
      # We have a <speak> tag so we'll need Nokogiri
      n = Nokogiri::HTML(text)
      # But Nokogiri search is heavy, if we don't need to parse DateTime, skip this by checking for interpret-as attribute using String's .include? method
      if text.include?('interpret-as')
        n.search('say-as').each do |e|
          if e.get_attribute('interpret-as') == 'date'
            e.content = Date.parse(e.content).strftime('%Y-%m-%d')
          elsif e.get_attribute('interpret-as') == 'time'
            e.content = Time.parse(e.content).strftime('%H:%M')
          end
        end
      end
      # Return the <speak> formatted string to UneeQ
      n.at('body').inner_html
    else
      # We didn't have any <speak> tags, so just return the string as-is
      text
    end
  end

  def return_new_session
    # Setup a new Dialogflow session object
    @session_client.class.session_path @project_id, @session_id
  end

  def send_query_to_dialogflow(session)
    # Create a query_input hash for readability
    query_input = { text: { text: @query, language_code: @language_code } }
    response = session_client.detect_intent session, query_input
    # parse the response from Dialogflow which is a Ruby object into JSON
    JSON.parse(response.query_result.to_json)
  end

  def generate_html(res)
    { 'html' => res['parameters']['displayHtml'] }
  end

  def generate_event(res, type)
    JSON.parse(res['parameters'][type.to_s])
  end

  def setup_instructions(res)
    instructions = {}
    if res['parameters']['emotionalTone']
      instructions['emotionalTone'] = generate_event(res, 'emotionalTone')
    end
    if res['parameters']['expressionEvent']
      instructions['expressionEvent'] = generate_event(res, 'expressionEvent')
    end
    if res['parameters']['displayHtml']
      instructions['displayHtml'] = generate_html(res)
    end
    instructions
  end

  # If there is any context information, store it in the response
  def set_matched_context(res)
    if res['outputContexts'].is_a?(Array)
      context = res['outputContexts'].map { |x| x['name'] }
    end
    # Dump the unnecessary projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/ stuff
    context.map! { |c| c.split('.').last }
    # Dump anything that isn't the right kind of context, mega, system counters, etc.
    context.reject! { |e| e.include?('projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/') }
    context
  end

  # If there is any payload information, store it in the response
  def set_conversation_payload(res)
    payload = {}
    payload = res['parameters'] if res['parameters'].is_a?(Hash)
  end

  def generate_json_string(data)
    JSON.generate(data)
  end

  def create_json_to_send(text)
    answer_body = {
      "answer": text,
      instructions: setup_instructions(@res)
      # "instructions": {
      #     "expressionEvent": [
      #       expression
      #     ],
      #     "emotionalTone": [
      #         {
      #             "tone": "happiness", # desired emotion in lowerCamelCase
      #             "value": 0.5, # number, intensity of the emotion to express between 0.0 and 1.0
      #             "start": 2, # number, in seconds from the beginning of the utterance to display the emotion
      #             "duration": 4, # number, duration in seconds this emotion should apply
      #             "additive": true, # boolean, whether the emotion should be added to existing emotions (true), or replace existing ones (false)
      #             "default": true # boolean, whether this is the default emotion
      #         }
      #     ],
      #     "displayHtml": {
      #         "html": html
      #     }
      # }
    }

    body = {
      "answer": generate_json_string(answer_body),
      # "matchedContext": "#{set_matched_context(@res)}",
      "matchedContext": '',
      "conversationPayload": "{context: #{set_matched_context(@res)}, parameters: #{set_conversation_payload(@res)}}"
      # "conversationPayload": ""
    }
    body
  end
end
