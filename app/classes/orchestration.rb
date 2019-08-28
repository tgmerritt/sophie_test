class Orchestration
    def initialize(query, conversation_state = nil, partner)
        @query = query # string, query from the STT engine of UneeQ
        @conversation_state = conversation_state # Maintain conversation state between utterances
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
        hound = Houndify.new
        hound.set_conversation_state(@conversation_state) if @conversation_state
        @response = hound.query(@query)
    end

    def orchestrate
        determine_partner
        map_response_to_uneeq_json
    end

    def map_response_to_uneeq_json
        case @partner
        when "Houndify"
            handle_houndify_daily_limit
        else
            return nil
        end
    end

    def handle_houndify_daily_limit
        if @response[:Error]
            create_json_to_send("Sorry, I cannot answer that right now", nil)
        else
            text = @response["AllResults"][0]["WrittenResponseLong"]
            create_json_to_send(text, houndify_combined_html(houndify_html, houndify_html_assets))
        end
    end

    def houndify_combined_html(html, html_assets)
        if html.nil?
            combined_html = nil
        else
            css = html_assets["CSS"].gsub(/\"/, '\'')
            js = html_assets["JS"].gsub(/\"/, '\'')
            combined_html = css + js + html
            combined_html.gsub!(/[\r\n]+/, ' ')
        end
    end

    def houndify_html_assets
        if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["HTMLHead"]
            @response["AllResults"][0]["HTMLData"]["HTMLHead"]
        else
            nil
        end
    end

    def houndify_html
        if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
            @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
        else
            nil
        end
    end

    def houndify_conversation_state
        if @response["AllResults"] && @response["AllResults"][0]["ConversationState"]
            generate_json_string(@response["AllResults"][0]["ConversationState"])
        else
            ""
        end
    end

    def generate_json_string(data)
        JSON.generate(data)
    end

    def create_json_to_send(text, html)
        answer_body = {
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
                ],
                "displayHtml": {
                    "html": html
                }
            }
        }

        body = {
            "answer": generate_json_string(answer_body),         
            "matchedContext": "",
            "conversationPayload": houndify_conversation_state,
        }
        return body
    end
end
