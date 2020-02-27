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
    n = Nokogiri::HTML(text)
    if n.search('say-as').any?
      n.search('say-as').each do |e|
        if e.get_attribute('interpret-as') == "date"
          e.content = Date.parse(e.content).strftime('%Y-%m-%d')
        elsif e.get_attribute('interpret-as') == "time"
          e.content = Time.parse(e.content).strftime("%H:%M")
        end
      end
      return n.at('body').inner_html
    else
      return n.at('body').text
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

  # Check if we have an expressionEvent in the payload, add it to instructions
  def generate_expression(res, instructions)
    # JSON may be faster than accessing the Ruby object
    if res['parameters']['expressionEvent']
      instructions['expressionEvent'] = JSON.parse(res['parameters']['expressionEvent'])
    end
    instructions
  end

  # Check if we have an emotionalEvent in the payload, add it to instructions
  def generate_emotion(res, instructions)
    if res['parameters']['emotionalTone']
      instructions['emotionalTone'] = JSON.parse(res['parameters']['emotionalTone'])
    end
    instructions
  end

  # If there is any context information, store it in the response
  def set_matched_context(res)
    context = []
    context = res["outputContexts"].map { |x| x["name"] } if res["outputContexts"].is_a?(Array)
    context
  end

  # If there is any payload information, store it in the response
  def set_conversation_payload(res)
    payload = {}
    payload = res["parameters"] if res["parameters"].is_a?(Hash)
  end

  def generate_json_string(data)
    JSON.generate(data)
  end

  def setup_instructions(res)
    instructions = generate_expression(res, {})
    instructions = generate_emotion(res, instructions)
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
      "matchedContext": "",
      # "conversationPayload": "#{set_conversation_payload(@res)}"
      "conversationPayload": ""
    }
    puts body
    body
  end
end

# jp train reservation demo start

