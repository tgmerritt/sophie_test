class WeatherHook
    # This is going to be the webhook for Weather with Dialogflow - stubbing out for now
    def initialize(params = {})
        params.each { |key,value| instance_variable_set("@#{key}", value) }
        @fulfillment_text, @location = nil
        instance_variables.each {|var| self.class.send(:attr_accessor, var.to_s.delete('@'))}
    end

    def set_defaults
        # only call if you need to initialize a default value for some attr
    end

    def evaluate
        # response = call_weather_service
        build_json_response(call_weather_service)
    end

    def build_json_response(response)
        temp = response.parsed_response["main"]["temp"]
        high = response.parsed_response["main"]["temp_max"]
        low = response.parsed_response["main"]["temp_min"]
        humidity = response.parsed_response["main"]["humidity"]
        pressure = response.parsed_response["main"]["pressure"]
        location_name = response.parsed_response["name"]
        description = response.parsed_response["weather"][0]["description"]
        {
            "fulfillmentText": "#{location_name}で今日の天気は#{description}と今の温度は#{temp}どです。高音は#{high}ど。低音は#{low}ど。湿度は#{humidity}パーセント。気圧は#{pressure}ミリバール"
        }
    end

    def extract_location
        # Grab the three possible values, URI encode for ASCII support in URL
        # Some values are possibly not present, so reject from the array
        # Output a final string with the existing values populated
        @location = [URI.encode(self.queryResult["parameters"]["address"]["city"]),URI.encode(self.queryResult["parameters"]["address"]["admin-area"]),URI.encode(self.queryResult["parameters"]["address"]["country"])]
        @location.reject!(&:blank?)
        @location = @location.join(",")
    end

    def call_weather_service
        extract_location
        HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{self.location}&appid=#{Rails.application.secrets.weather_service_api}&units=metric&lang=ja")
    end
end

# Sample Webhook Response payload to Dialogflow
# {
#     "fulfillmentText": "This is a text response",
#     "fulfillmentMessages": [
#       {
#         "card": {
#           "title": "card title",
#           "subtitle": "card text",
#           "imageUri": "https://example.com/images/example.png",
#           "buttons": [
#             {
#               "text": "button text",
#               "postback": "https://example.com/path/for/end-user/to/follow"
#             }
#           ]
#         }
#       }
#     ],
#     "source": "example.com",
#     "payload": {
#       "google": {
#         "expectUserResponse": true,
#         "richResponse": {
#           "items": [
#             {
#               "simpleResponse": {
#                 "textToSpeech": "this is a simple response"
#               }
#             }
#           ]
#         }
#       },
#       "facebook": {
#         "text": "Hello, Facebook!"
#       },
#       "slack": {
#         "text": "This is a text response for Slack."
#       }
#     },
#     "outputContexts": [
#       {
#         "name": "projects/project-id/agent/sessions/session-id/contexts/context-name",
#         "lifespanCount": 5,
#         "parameters": {
#           "param-name": "param-value"
#         }
#       }
#     ],
#     "followupEventInput": {
#       "name": "event name",
#       "languageCode": "en-US",
#       "parameters": {
#         "param-name": "param-value"
#       }
#     }
#   }