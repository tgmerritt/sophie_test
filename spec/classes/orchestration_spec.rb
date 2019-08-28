require 'rails_helper'

RSpec.describe Orchestration do
  context "With valid Houndify JSON" do
    let(:json_data) { JSON.load(file_fixture("houndify_response.json").read) }
    before(:each) do 
      Houndify.any_instance.stub(:query).and_return(json_data)
    end
    params = {
      "fm-question" => "What is the weather in Pensacola, FL?",
      "fm-custom-data" => "{\"latitude\":\"33.2323248\",\"longitude\":\"33.2323248\"}"
    }
    let (:response) { Orchestration.new(params, "Houndify").orchestrate }
    
    it "ensures Orchestration is newed up correctly" do 
      params = {
        "fm-question" => "What is the weather in Pensacola, FL?",
        "fm-conversation" => "",
        "fm-custom-data" => "{\"latitude\":\"33.2323248\",\"longitude\":\"33.2323248\"}"
      }
      o = Orchestration.new(params, "Houndify")
      expect(o).to be_instance_of(Orchestration)
      expect(o.location).to eq ({"latitude"=>"33.2323248", "longitude"=>"33.2323248"})
      expect(o.query).to eq "What is the weather in Pensacola, FL?"
      expect(o.conversation_state).to eq nil
    end

    it "will not new up Orchestration if wrong arguments are passed" do
      expect{ Orchestration.new("Houndify") }.to raise_error(ArgumentError)
    end
    
    it "returns an expected JSON object" do 
      expect(response[:answer]).to eq (
          "{\"answer\":\"The weather is 84 °F and mostly cloudy near Prosper, Texas.\",\"instructions\":{\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}],\"displayHtml\":{\"html\":\"<link rel='stylesheet' href='//static.midomi.com/corpus/H_Zk82fGHFX/build/css/templates.min.css'><script src='//static.midomi.com/corpus/H_Zk82fGHFX/build/js/templates.min.js'></script><div class='h-template h-image-carousel-wrapper'>   <div class='h-image-carousel h-image-carousel-Small' data-carousel-id=h-image-carousel-0><img src=http://static.midomi.com/h/images/w/weather_mostlycloudy.png>   </div> </div> <div class='h-template h-two-col-table-wrapper'>   <table class='h-template-table h-two-col-table pure-table pure-table-horizontal'>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Temperature       </td>       <td class='h-template-cell h-two-col-table-right-text'>84 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Temperature Feels Like       </td>       <td class='h-template-cell h-two-col-table-right-text'>90 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind Chill       </td>       <td class='h-template-cell h-two-col-table-right-text'>85 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Dew Point       </td>       <td class='h-template-cell h-two-col-table-right-text'>72 °F       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Percent Humidity       </td>       <td class='h-template-cell h-two-col-table-right-text'>66%       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Visibility       </td>       <td class='h-template-cell h-two-col-table-right-text'>9 mi       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Precipitation for the Next Hour       </td>       <td class='h-template-cell h-two-col-table-right-text'>0 in       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Precipitation Today       </td>       <td class='h-template-cell h-two-col-table-right-text'>0.9 in       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind       </td>       <td class='h-template-cell h-two-col-table-right-text'>4 mph 338°NNW       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Wind Gust       </td>       <td class='h-template-cell h-two-col-table-right-text'>7 mph       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>Barometric Pressure       </td>       <td class='h-template-cell h-two-col-table-right-text'>29.94 inHg and Steady       </td>     </tr>     <tr>       <td class='h-template-cell h-two-col-table-left-text'>UV Index       </td>       <td class='h-template-cell h-two-col-table-right-text'>0 (Low)       </td>     </tr>   </table> </div> \"}}}"
      )   
    end

    it "handles a conversation payload" do
      expect(response[:conversationPayload]).to eq (
        "{\"ConversationStateTime\":1566958100,\"QueryEntities\":{\"Where\":[{\"Type\":\"City\",\"Label\":\"Prosper, Texas\",\"SpokenLabel\":\"Prosper Texas\",\"Address\":\"Prosper, Texas, United States\",\"City\":\"Prosper\",\"Admin2\":\"Collin County\",\"Admin1\":\"Texas\",\"Country\":\"United States\",\"CountryCode\":\"US\",\"Geohash\":\"9vgjj4rx4djk\",\"Verified\":true,\"HighConfidence\":true,\"CurrentLocation\":false,\"Latitude\":33.23622894287109,\"Longitude\":-96.80110931396484,\"ReferenceDatum\":\"WGS84\",\"TimeZone\":\"America/Chicago\",\"Radius\":6,\"BoundingBox\":{\"MinLat\":33.21853256225586,\"MaxLat\":33.26287460327148,\"MinLon\":-96.89806365966797,\"MaxLon\":-96.73248291015625},\"Links\":[{\"Label\":\"Wikipedia\",\"URL\":\"http://en.wikipedia.org/wiki/Prosper%2C_Texas\"}],\"TypeID\":5,\"SourceID\":2,\"RecordID\":4720833}]},\"ShowWeatherCurrentConditionsQueryHistory\":[{\"WeatherKind\":\"ShowWeatherCurrentConditions\",\"WeatherQueryType\":\"Current\",\"RequestedAttribute\":\"generic\",\"MapLocation\":{\"Type\":\"City\",\"Label\":\"Prosper, Texas\",\"SpokenLabel\":\"Prosper Texas\",\"Address\":\"Prosper, Texas, United States\",\"City\":\"Prosper\",\"Admin2\":\"Collin County\",\"Admin1\":\"Texas\",\"Country\":\"United States\",\"CountryCode\":\"US\",\"Geohash\":\"9vgjj4rx4djk\",\"Verified\":true,\"HighConfidence\":true,\"CurrentLocation\":false,\"Latitude\":33.23622894287109,\"Longitude\":-96.80110931396484,\"ReferenceDatum\":\"WGS84\",\"TimeZone\":\"America/Chicago\",\"Radius\":6,\"BoundingBox\":{\"MinLat\":33.21853256225586,\"MaxLat\":33.26287460327148,\"MinLon\":-96.89806365966797,\"MaxLon\":-96.73248291015625},\"Links\":[{\"Label\":\"Wikipedia\",\"URL\":\"http://en.wikipedia.org/wiki/Prosper%2C_Texas\"}],\"TypeID\":5,\"SourceID\":2,\"RecordID\":4720833},\"Units\":\"US\"}]}"
      )
    end
  
    it "handles no conversation payload" do
      json_data["AllResults"][0]["ConversationState"] = ""
      res = Orchestration.new("What is the weather in Pensacola, FL?", "Houndify").orchestrate
      expect(res[:conversationPayload]).to eq "\"\""
    end
  end
  
  context "With invalid JSON or Error" do 
    it "handles over daily limit Houndify error" do
      json_data = {Error: "Over daily limit\n"}
      Houndify.any_instance.stub(:query).and_return(json_data)

      o = Orchestration.new("What is the weather in Pensacola, FL?", "Houndify")
      response = o.orchestrate
      expect(response[:answer]).to eq (
          "{\"answer\":\"Sorry, I cannot answer that right now\",\"instructions\":{\"emotionalTone\":[{\"tone\":\"happiness\",\"value\":0.5,\"start\":2,\"duration\":4,\"additive\":true,\"default\":true}],\"displayHtml\":{\"html\":null}}}"
      )
    end
  end
end