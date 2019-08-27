class Orchestration
    def initialize(query, partner)
        @query = query # string, query from the STT engine of UneeQ
        @partner = partner # string, the name of the partner company we reach out to
        @response = nil
    end

    def determine_partner
        case @partner
        when "Houndify"
            query_houndify
        else 
            return nil
        end
    end

    def query_houndify
        @response = Houndify.new.query(@query)
    end

    def orchestrate
        determine_partner
        map_response_to_uneeq_json
    end

    def map_response_to_uneeq_json
        case @partner
        when "Houndify"
            html = nil
            html_assets = nil
            text = @response["AllResults"][0]["WrittenResponseLong"]
            if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["HTMLHead"]
                html_assets = @response["AllResults"][0]["HTMLData"]["HTMLHead"]
            end
            if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
                html = @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
            end
            combined_html = "#{html_assets} #{html}"
            create_json_to_send(text, combined_html)
        else
            return nil
        end
    end

    def create_json_to_send(text, html)
        # headers = {
        #     "Content-Type": "application/jwt",
        #     "workspace": Rails.application.secrets.workspace_id
        # }
        body = {
            "ANSWER": {
                "answer": text,
                "instructions": {
                    # "expressionEvent": [
                    #     {
                    #         "expression": "headPitch", # string, a supported expression in lowerCamelCase
                    #         "value": 0.5, # number, intensity. Range varies depending on the expression
                    #         "start": 2 # number, in seconds from start of the utterance
                    #         "duration": 5 # number, duration in seconds this expression 
                    #     }
                    # ],
                    "emotionalTone": [
                        {
                            "tone": "happiness", # desired emotion in lowerCamelCase
                            "value": 0.5, # number, intensity of the emotion to express between 0.0 and 1.0 
                            "start": 2, # number, in seconds from the beginning of the utterance to display the emotion
                            "duration": 4, # number, duration in seconds this emotion should apply
                            "additive": true, # boolean, whether the emotion should be added to existing emotions (true), or replace existing ones (false)
                            "default": true # boolean, whether this is the default emotion 
                        }
                    ]
                    # "displayHtml": {
                    #     "html": html
                    # }
                }
            },
            "CONVERSATION_PAYLOAD": "",
            "MATCHED_CONTEXT": "",
            # "ERROR_DESCRIPTION": "A description of the error which has occurred" # This is irrelevant if the conversation is successful
        }
        return body
    end
end
