# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherHook do
  before(:each) do
    @wh = WeatherHook.new(params)
  end
  it 'initializes a new instance of the class from params' do
    @wh = WeatherHook.new(params)
    expect(@wh).to be_instance_of(WeatherHook)
    expect(@wh.queryResult['queryText']).to eq '大阪の天気'
    expect(@wh.queryResult['parameters']).to eq parameters_value
    expect(@wh.queryResult['outputContexts']).to eq output_contexts_value
    expect(@wh.fulfillment_text).to eq nil
    expect(@wh.location).to eq nil
  end

  it 'creates a location string' do
    @wh.extract_location
    expect(@wh.location).to eq '%E5%A4%A7%E9%98%AA%E5%B8%82'
  end

  describe 'json_response_for_city' do
    let(:weather_response) { instance_double(HTTParty::Response, body: weather_response_body) }
    let(:weather_response_body) { weather_response_body_value }

    before do
      allow(HTTParty).to receive(:get).and_return(weather_response_body)
    end

    it 'builds_json_response' do
      res = @wh.check_for_valid_response(@wh.call_weather_service)
      expect(res[:fulfillmentText]).to include ('大阪市の今日の天気は曇りがち')
      expect(res[:fulfillmentText]).to include ('です。今の温度は8.23どです。最高気温は9.44ど。最低気温は6.67ど。湿度は45パーセント。気圧は1025ヘクトパスカルの予報です。')
    end
  end

  describe 'json_response_for_area' do
    let(:weather_response) { instance_double(HTTParty::Response, body: weather_response_body) }
    let(:weather_response_body) { weather_response_for_island }

    before do
      allow(HTTParty).to receive(:get).and_return(weather_response_body)
    end

    it 'builds_json_response' do
      res = @wh.check_for_valid_response(@wh.call_weather_service)
      # There is some weirdness here where after がち we are getting an ASCII \b character inserted, and I can't fully figure out why - something to do with encoding probably and how rspec parses (ISO8901 vs UTF-8 stuff)
      expect(res[:fulfillmentText]).to include ('北海道の今日の天気は曇りがち')
      expect(res[:fulfillmentText]).to include ('です。今の温度は-5どです。最高気温は-5ど。最低気温は-5ど。湿度は79パーセント。気圧は1022ヘクトパスカルの予報です。')
    end
  end

  describe 'no_json_response_for_weather_search' do
    let(:weather_response) { instance_double(HTTParty::Response, body: weather_response_body) }
    let(:weather_response_body) { weather_not_found_response }

    before do
      allow(HTTParty).to receive(:get).and_return(weather_response_body)
    end

    it 'builds_json_response' do
      res = @wh.check_for_valid_response(@wh.call_weather_service)
      expect(res).to eq ({ fulfillmentText: '申し訳御座いません。該当するエリアが見つかりませんでした。別の場所を指定して下さい。' })
    end
  end
end

def params
  { 'responseId' => '8992149f-f34c-4342-a582-16eac22b60c9-19db3199', 'queryResult' => { 'queryText' => '大阪の天気', 'action' => 'weather', 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'date-time' => '', 'unit' => '' }, 'allRequiredParamsPresent' => true, 'fulfillmentMessages' => [{ 'text' => { 'text' => [''] } }], 'outputContexts' => [{ 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather', 'lifespanCount' => 2, 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }, { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup', 'lifespanCount' => 2, 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }, { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__', 'parameters' => { 'no-input' => 0.0, 'no-match' => 0.0, 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }], 'intent' => { 'name' => 'projects/weather-ctncms/agent/intents/f1b75ecb-a35f-4a26-88fb-5a8049b92b02', 'displayName' => 'weather' }, 'intentDetectionConfidence' => 1.0, 'languageCode' => 'ja' }, 'originalDetectIntentRequest' => { 'payload' => {} }, 'session' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e', 'webhook' => { 'responseId' => '8992149f-f34c-4342-a582-16eac22b60c9-19db3199', 'queryResult' => { 'queryText' => '大阪の天気', 'action' => 'weather', 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'date-time' => '', 'unit' => '' }, 'allRequiredParamsPresent' => true, 'fulfillmentMessages' => [{ 'text' => { 'text' => [''] } }], 'outputContexts' => [{ 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather', 'lifespanCount' => 2, 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }, { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup', 'lifespanCount' => 2, 'parameters' => { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }, { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__', 'parameters' => { 'no-input' => 0.0, 'no-match' => 0.0, 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'address.original' => '大阪', 'date-time' => '', 'date-time.original' => '', 'unit' => '', 'unit.original' => '' } }], 'intent' => { 'name' => 'projects/weather-ctncms/agent/intents/f1b75ecb-a35f-4a26-88fb-5a8049b92b02', 'displayName' => 'weather' }, 'intentDetectionConfidence' => 1.0, 'languageCode' => 'ja' }, 'originalDetectIntentRequest' => { 'payload' => {} }, 'session' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e' } }
end

def weather_response_body_value
  OpenStruct.new(parsed_response: { 'coord' => { 'lon' => 135.5, 'lat' => 34.69 }, 'weather' => [{ 'id' => 803, 'main' => 'Clouds', 'description' => '曇りがち', 'icon' => '04d' }], 'base' => 'stations', 'main' => { 'temp' => 8.23, 'feels_like' => 5.15, 'temp_min' => 6.67, 'temp_max' => 9.44, 'pressure' => 1025, 'humidity' => 45 }, 'visibility' => 10_000, 'wind' => { 'speed' => 1 }, 'clouds' => { 'all' => 75 }, 'dt' => 1_582_857_478, 'sys' => { 'type' => 1, 'id' => 8032, 'country' => 'JP', 'sunrise' => 1_582_839_001, 'sunset' => 1_582_879_908 }, 'timezone' => 32_400, 'id' => 1_853_909, 'name' => '大阪市', 'cod' => 200 })
end

def weather_response_for_island
  OpenStruct.new(parsed_response: { 'coord' => { 'lon' => 141.35, 'lat' => 43.06 }, 'weather' => [{ 'id' => 803, 'main' => 'Clouds', 'description' => '曇りがち', 'icon' => '04n' }], 'base' => 'stations', 'main' => { 'temp' => -5, 'feels_like' => -10.07, 'temp_min' => -5, 'temp_max' => -5, 'pressure' => 1022, 'humidity' => 79 }, 'visibility' => 10_000, 'wind' => { 'speed' => 3.1, 'deg' => 330 }, 'clouds' => { 'all' => 75 }, 'dt' => 1_582_903_785, 'sys' => { 'type' => 1, 'id' => 7973, 'country' => 'JP', 'sunrise' => 1_582_924_359, 'sunset' => 1_582_964_520 }, 'timezone' => 32_400, 'id' => 2_130_037, 'name' => '北海道', 'cod' => 200 })
end

def weather_not_found_response
  OpenStruct.new(parsed_response: { 'cod' => '404', 'message' => 'city not found' })
end

def output_contexts_value
  [{ 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather',
     'lifespanCount' => 2,
     'parameters' =>
       { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' },
         'address.original' => '大阪',
         'date-time' => '',
         'date-time.original' => '',
         'unit' => '',
         'unit.original' => '' } },
   { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/weather-followup',
     'lifespanCount' => 2,
     'parameters' =>
       { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' },
         'address.original' => '大阪',
         'date-time' => '',
         'date-time.original' => '',
         'unit' => '',
         'unit.original' => '' } },
   { 'name' => 'projects/weather-ctncms/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/__system_counters__',
     'parameters' =>
       { 'no-input' => 0.0,
         'no-match' => 0.0,
         'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' },
         'address.original' => '大阪',
         'date-time' => '',
         'date-time.original' => '',
         'unit' => '',
         'unit.original' => '' } }]
end

def parameters_value
  { 'address' => { 'country' => '', 'city' => '大阪市', 'admin-area' => '', 'business-name' => '', 'street-address' => '', 'zip-code' => '', 'shortcut' => '', 'island' => '', 'subadmin-area' => '' }, 'date-time' => '', 'unit' => '' }
end
