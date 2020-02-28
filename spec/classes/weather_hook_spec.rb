require 'rails_helper'

RSpec.describe WeatherHook do
    before(:each) do 
        @wh = WeatherHook.new(params)
    end
    it "initializes a new instance of the class from params" do 
        @wh = WeatherHook.new(params)
        expect(@wh).to be_instance_of(WeatherHook)
        expect(@wh.queryResult["queryText"]).to eq "大阪の天気"
        expect(@wh.queryResult["parameters"]).to eq parameters_value
        expect(@wh.queryResult["outputContexts"]).to eq output_contexts_value
        expect(@wh.fulfillment_text).to eq nil
        expect(@wh.location).to eq nil
    end

    it "creates a location string" do
        @wh.extract_location
        expect(@wh.location).to eq "%E5%A4%A7%E9%98%AA%E5%B8%82"
    end

    describe 'json_response' do 
        let(:weather_response) { instance_double(HTTParty::Response, body: weather_response_body) }
        let(:weather_response_body) { weather_response_body_value }
        
        before do
            allow(HTTParty).to receive(:get).and_return(weather_response_body)
        end
        
        it "builds_json_response" do
            res = @wh.build_json_response(@wh.call_weather_service)
            expect(res).to eq ({:fulfillmentText=>"大阪市で今日の天気は曇りがちと今の温度は8.23どです。高音は9.44ど。低音は6.67ど。湿度は45パーセント。気圧は1025ミリバール"})
        end
    end
end

def params
    {"responseId"=>"8992149f-f34c-4342-a582-16eac22b60c9-19db3199", "queryResult"=>{"queryText"=>"大阪の天気", "action"=>"weather", "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "date-time"=>"", "unit"=>""}, "allRequiredParamsPresent"=>true, "fulfillmentMessages"=>[{"text"=>{"text"=>[""]}}], "outputContexts"=>[{"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather", "lifespanCount"=>2, "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}, {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup", "lifespanCount"=>2, "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}, {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__", "parameters"=>{"no-input"=>0.0, "no-match"=>0.0, "address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}], "intent"=>{"name"=>"projects/weather-ctncms/agent/intents/f1b75ecb-a35f-4a26-88fb-5a8049b92b02", "displayName"=>"weather"}, "intentDetectionConfidence"=>1.0, "languageCode"=>"ja"}, "originalDetectIntentRequest"=>{"payload"=>{}}, "session"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e", "webhook"=>{"responseId"=>"8992149f-f34c-4342-a582-16eac22b60c9-19db3199", "queryResult"=>{"queryText"=>"大阪の天気", "action"=>"weather", "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "date-time"=>"", "unit"=>""}, "allRequiredParamsPresent"=>true, "fulfillmentMessages"=>[{"text"=>{"text"=>[""]}}], "outputContexts"=>[{"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather", "lifespanCount"=>2, "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}, {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup", "lifespanCount"=>2, "parameters"=>{"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}, {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__", "parameters"=>{"no-input"=>0.0, "no-match"=>0.0, "address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "address.original"=>"大阪", "date-time"=>"", "date-time.original"=>"", "unit"=>"", "unit.original"=>""}}], "intent"=>{"name"=>"projects/weather-ctncms/agent/intents/f1b75ecb-a35f-4a26-88fb-5a8049b92b02", "displayName"=>"weather"}, "intentDetectionConfidence"=>1.0, "languageCode"=>"ja"}, "originalDetectIntentRequest"=>{"payload"=>{}}, "session"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e"}}
end

def weather_response_body_value
    OpenStruct.new({:parsed_response => {"coord"=>{"lon"=>135.5, "lat"=>34.69}, "weather"=>[{"id"=>803, "main"=>"Clouds", "description"=>"曇りがち", "icon"=>"04d"}], "base"=>"stations", "main"=>{"temp"=>8.23, "feels_like"=>5.15, "temp_min"=>6.67, "temp_max"=>9.44, "pressure"=>1025, "humidity"=>45}, "visibility"=>10000, "wind"=>{"speed"=>1}, "clouds"=>{"all"=>75}, "dt"=>1582857478, "sys"=>{"type"=>1, "id"=>8032, "country"=>"JP", "sunrise"=>1582839001, "sunset"=>1582879908}, "timezone"=>32400, "id"=>1853909, "name"=>"大阪市", "cod"=>200}})
end

def output_contexts_value
    [{"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather",
        "lifespanCount"=>2,
        "parameters"=>
         {"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""},
          "address.original"=>"大阪",
          "date-time"=>"",
          "date-time.original"=>"",
          "unit"=>"",
          "unit.original"=>""}},
       {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup",
        "lifespanCount"=>2,
        "parameters"=>
         {"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""},
          "address.original"=>"大阪",
          "date-time"=>"",
          "date-time.original"=>"",
          "unit"=>"",
          "unit.original"=>""}},
       {"name"=>"projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__",
        "parameters"=>
         {"no-input"=>0.0,
          "no-match"=>0.0,
          "address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""},
          "address.original"=>"大阪",
          "date-time"=>"",
          "date-time.original"=>"",
          "unit"=>"",
          "unit.original"=>""}}]
end

def parameters_value
    {"address"=>{"country"=>"", "city"=>"大阪市", "admin-area"=>"", "business-name"=>"", "street-address"=>"", "zip-code"=>"", "shortcut"=>"", "island"=>"", "subadmin-area"=>""}, "date-time"=>"", "unit"=>""}
end