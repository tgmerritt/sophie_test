# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orchestration do
  context 'With valid Houndify JSON' do
    let(:json_data) { JSON.load(file_fixture('houndify_response.json').read) }
    before(:each) do
      Houndify.any_instance.stub(:query).and_return(json_data)
    end
    params = {
      'fm-question' => 'What is the weather in Pensacola, FL?',
      'fm-custom-data' => '{"latitude":"33.2323248","longitude":"33.2323248"}',
      'fm-avatar' => { "type": 'WELCOME',
                       "avatarSessionId": '632c2f78-ca23-4cc2-8c1a-ad8e2403ca64' }
    }
    let (:response) { Orchestration.new(params, 'Houndify').orchestrate }

    it 'ensures Orchestration is newed up correctly' do
      params = {
        'fm-question' => 'What is the weather in Pensacola, FL?',
        'fm-conversation' => '',
        'fm-custom-data' => '{"latitude":"33.2323248","longitude":"33.2323248"}',
        'fm-avatar' => { "type": 'WELCOME',
                         "avatarSessionId": '632c2f78-ca23-4cc2-8c1a-ad8e2403ca64' }
      }
      o = Orchestration.new(params, 'Houndify')
      expect(o).to be_instance_of(Orchestration)
      expect(o.location).to eq ({ 'latitude' => '33.2323248', 'longitude' => '33.2323248' })
      expect(o.query).to eq 'What is the weather in Pensacola, FL?'
      expect(o.conversation_state).to eq nil
    end

    it 'will not new up Orchestration if wrong arguments are passed' do
      expect { Orchestration.new('Houndify') }.to raise_error(ArgumentError)
    end

    it 'returns an expected JSON object' do
      expect(response[:answer]).to include("The weather is 84 °F and mostly cloudy near Prosper, Texas.")
      expect(response[:answer]).to include("expressionEvent")
      expect(response[:answer]).to include("\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}]")
      expect(response[:answer]).to include("displayHtml")
    end

    it 'handles a conversation payload' do
      expect(response[:conversationPayload]).to eq '{"ConversationStateTime":1566958100,"QueryEntities":{"Where":[{"Type":"City","Label":"Prosper, Texas","SpokenLabel":"Prosper Texas","Address":"Prosper, Texas, United States","City":"Prosper","Admin2":"Collin County","Admin1":"Texas","Country":"United States","CountryCode":"US","Geohash":"9vgjj4rx4djk","Verified":true,"HighConfidence":true,"CurrentLocation":false,"Latitude":33.23622894287109,"Longitude":-96.80110931396484,"ReferenceDatum":"WGS84","TimeZone":"America/Chicago","Radius":6,"BoundingBox":{"MinLat":33.21853256225586,"MaxLat":33.26287460327148,"MinLon":-96.89806365966797,"MaxLon":-96.73248291015625},"Links":[{"Label":"Wikipedia","URL":"http://en.wikipedia.org/wiki/Prosper%2C_Texas"}],"TypeID":5,"SourceID":2,"RecordID":4720833}]},"ShowWeatherCurrentConditionsQueryHistory":[{"WeatherKind":"ShowWeatherCurrentConditions","WeatherQueryType":"Current","RequestedAttribute":"generic","MapLocation":{"Type":"City","Label":"Prosper, Texas","SpokenLabel":"Prosper Texas","Address":"Prosper, Texas, United States","City":"Prosper","Admin2":"Collin County","Admin1":"Texas","Country":"United States","CountryCode":"US","Geohash":"9vgjj4rx4djk","Verified":true,"HighConfidence":true,"CurrentLocation":false,"Latitude":33.23622894287109,"Longitude":-96.80110931396484,"ReferenceDatum":"WGS84","TimeZone":"America/Chicago","Radius":6,"BoundingBox":{"MinLat":33.21853256225586,"MaxLat":33.26287460327148,"MinLon":-96.89806365966797,"MaxLon":-96.73248291015625},"Links":[{"Label":"Wikipedia","URL":"http://en.wikipedia.org/wiki/Prosper%2C_Texas"}],"TypeID":5,"SourceID":2,"RecordID":4720833},"Units":"US"}]}'
    end

    it 'handles no conversation payload' do
      json_data['AllResults'][0]['ConversationState'] = ''
      res = Orchestration.new('What is the weather in Pensacola, FL?', 'Houndify').orchestrate
      expect(res[:conversationPayload]).to eq '""'
    end
  end

  context 'With invalid JSON or Error' do
    it 'handles over daily limit Houndify error' do
      json_data = { Error: "Over daily limit\n" }
      Houndify.any_instance.stub(:query).and_return(json_data)

      o = Orchestration.new('What is the weather in Pensacola, FL?', 'Houndify')
      response = o.orchestrate
      expect(response[:answer]).to eq '{"answer":"Sorry, I cannot answer that right now","instructions":{"expressionEvent":[{}],"emotionalTone":[{"tone":"happiness","value":0.5,"start":2,"duration":4,"additive":true,"default":true}],"displayHtml":{"html":null}}}'
    end
  end

  context 'With emotion in the Houndify response' do
    let(:json_data) { JSON.load(file_fixture('houndify_emotion_response.json').read) }
    before(:each) do
      Houndify.any_instance.stub(:query).and_return(json_data)
    end
    params = {
      'fm-question' => 'What is the weather in Pensacola, FL?',
      'fm-custom-data' => '{"latitude":"33.2323248","longitude":"33.2323248"}',
      'fm-avatar' => { "type": 'WELCOME',
                       "avatarSessionId": '632c2f78-ca23-4cc2-8c1a-ad8e2403ca64' }
    }
    let (:response) { Orchestration.new(params, 'Houndify').orchestrate }
    it 'parses the emotion into a proper emotionalInstruction' do
      expect(response[:answer]).to include("{\"answer\":\"The CEO of unique is Danny Tomsett\"")
      expect(response[:answer]).to include("\"instructions\":{\"expressionEvent\":[{\"expression\":\"wink\",\"value\":0.5,\"start\":2,\"duration\":5}],\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}],")
      expect(response[:answer]).to include("<div class='h-template h-image-carousel-wrapper'>   <div class='h-image-carousel h-image-carousel-Small' data-carousel-id='h-image-carousel-0'><img src='http://i2.wp.com/www.makelemonade.nz/wp-content/uploads/2018/11/Danny-Tomsett.jpg'> <h1>Danny Tomsett</h1><caption>Giant among men</caption></div>   </div>\"}}}")
    end
  end
end
