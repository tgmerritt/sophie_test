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
        @language_code = "ja"
    end

    # Query Dialogflow using the Ruby gem
    def query_dialogflow
        session = @session_client.class.session_path @project_id, @session_id
        query_input = { text: { text: @query, language_code: @language_code } }
        response = session_client.detect_intent session, query_input
        res = JSON.parse(response.query_result.to_json)
        generate_expression(res, {})
        # generate_expression(response.query_result, {})
    end

    # Check if we have an expressionEvent in the payload, add it to instructions
    def generate_expression(query_result, instructions)
        # Here is the "Ruby" way to do this:
        # if query_result.parameters.fields["expressionEvent"]
        #     r = query_result.parameters.fields["expressionEvent"].string_value.gsub!(/\s+/,'')
        #     instructions["expressionEvent"] = JSON.parse(r)
        # end
        # But it may be faster to simply parse everything out as JSON as the C-bindings in the JSON gem should be wicked fast and less memory intensive
        instructions["expressionEvent"] = JSON.parse(query_result["parameters"]["expressionEvent"]) if query_result["parameters"]["expressionEvent"]
        generate_emotion(query_result, instructions)
    end

    # Check if we have an emotionalEvent in the payload, add it to instructions
    def generate_emotion(query_result, instructions)
        # if query_result.parameters.fields["emotionalTone"]
        #     r = query_result.parameters.fields["emotionalTone"].string_value.gsub!(/\s+/,'')
        #     instructions["emotionalTone"] = JSON.parse(r)
        # end
        instructions["emotionalTone"] = JSON.parse(query_result["parameters"]["emotionalTone"]) if query_result["parameters"]["emotionalTone"]
        # Finally send everything to the create_json method
        # create_json_to_send(query_result.fulfillment_text, "", instructions)
        create_json_to_send(query_result["fulfillmentText"], "", instructions)
    end

    def generate_json_string(data)
        JSON.generate(data)
    end
  
    def create_json_to_send(text, html, instructions)
        answer_body = {
            "answer": text,
            instructions: instructions
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
            "matchedContext": "",
            "conversationPayload": "",
        }
        return body
    end
end