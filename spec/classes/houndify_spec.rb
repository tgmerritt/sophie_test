require 'rails_helper'

RSpec.describe Houndify do
    it "adds a conversation_state to the object" do
        params = set_params
        hound = Houndify.new
        
        hound.set_conversation_state(JSON.parse(params["fm-conversation"]))

        expect(hound.hound_request_info["ConversationState"]).to eq (
            {"ConversationStateTime"=>1567007771,
                "QueryEntities"=>
                 {"Where"=>
                   [{"Type"=>"City",
                     "Label"=>"Dallas, Texas",
                     "SpokenLabel"=>"Dallas Texas",
                     "Address"=>"Dallas, Texas, United States",
                     "City"=>"Dallas",
                     "Admin2"=>"Dallas County",
                     "Admin1"=>"Texas",
                     "Country"=>"United States",
                     "CountryCode"=>"US",
                     "IATA"=>"DFW",
                     "Geohash"=>"9vg4mpgx1hfp",
                     "Verified"=>true,
                     "HighConfidence"=>true,
                     "CurrentLocation"=>false,
                     "Latitude"=>32.78305816650391,
                     "Longitude"=>-96.80667114257812,
                     "ReferenceDatum"=>"WGS84",
                     "TimeZone"=>"America/Chicago",
                     "Radius"=>22,
                     "BoundingBox"=>{"MinLat"=>32.61321640014648, "MaxLat"=>33.0237922668457, "MinLon"=>-97.00048065185547, "MaxLon"=>-96.4637222290039},
                     "Links"=>[{"Label"=>"Wikipedia", "URL"=>"http://en.wikipedia.org/wiki/Dallas"}],
                     "TypeID"=>5,
                     "SourceID"=>2,
                     "RecordID"=>4684888}]},
                "ShowWeatherCurrentConditionsQueryHistory"=>
                 [{"WeatherKind"=>"ShowWeatherCurrentConditions",
                   "WeatherQueryType"=>"Current",
                   "RequestedAttribute"=>"generic",
                   "MapLocation"=>
                    {"Type"=>"City",
                     "Label"=>"Dallas, Texas",
                     "SpokenLabel"=>"Dallas Texas",
                     "Address"=>"Dallas, Texas, United States",
                     "City"=>"Dallas",
                     "Admin2"=>"Dallas County",
                     "Admin1"=>"Texas",
                     "Country"=>"United States",
                     "CountryCode"=>"US",
                     "IATA"=>"DFW",
                     "Geohash"=>"9vg4mpgx1hfp",
                     "Verified"=>true,
                     "HighConfidence"=>true,
                     "CurrentLocation"=>false,
                     "Latitude"=>32.78305816650391,
                     "Longitude"=>-96.80667114257812,
                     "ReferenceDatum"=>"WGS84",
                     "TimeZone"=>"America/Chicago",
                     "Radius"=>22,
                     "BoundingBox"=>{"MinLat"=>32.61321640014648, "MaxLat"=>33.0237922668457, "MinLon"=>-97.00048065185547, "MaxLon"=>-96.4637222290039},
                     "Links"=>[{"Label"=>"Wikipedia", "URL"=>"http://en.wikipedia.org/wiki/Dallas"}],
                     "TypeID"=>5,
                     "SourceID"=>2,
                     "RecordID"=>4684888},
                   "Units"=>"US"}]}
        )
    end

    def set_params
        {"sid"=>"ebf0f3ff-364a-41e7-9bfd-bbbe41cfd570", "fm-custom-data"=>"", "fm-question"=>"How about Los Angeles", "fm-avatar"=>"", "fm-conversation"=>"{\"ConversationStateTime\":1567007771,\"QueryEntities\":{\"Where\":[{\"Type\":\"City\",\"Label\":\"Dallas, Texas\",\"SpokenLabel\":\"Dallas Texas\",\"Address\":\"Dallas, Texas, United States\",\"City\":\"Dallas\",\"Admin2\":\"Dallas County\",\"Admin1\":\"Texas\",\"Country\":\"United States\",\"CountryCode\":\"US\",\"IATA\":\"DFW\",\"Geohash\":\"9vg4mpgx1hfp\",\"Verified\":true,\"HighConfidence\":true,\"CurrentLocation\":false,\"Latitude\":32.78305816650391,\"Longitude\":-96.80667114257812,\"ReferenceDatum\":\"WGS84\",\"TimeZone\":\"America/Chicago\",\"Radius\":22,\"BoundingBox\":{\"MinLat\":32.61321640014648,\"MaxLat\":33.0237922668457,\"MinLon\":-97.00048065185547,\"MaxLon\":-96.4637222290039},\"Links\":[{\"Label\":\"Wikipedia\",\"URL\":\"http://en.wikipedia.org/wiki/Dallas\"}],\"TypeID\":5,\"SourceID\":2,\"RecordID\":4684888}]},\"ShowWeatherCurrentConditionsQueryHistory\":[{\"WeatherKind\":\"ShowWeatherCurrentConditions\",\"WeatherQueryType\":\"Current\",\"RequestedAttribute\":\"generic\",\"MapLocation\":{\"Type\":\"City\",\"Label\":\"Dallas, Texas\",\"SpokenLabel\":\"Dallas Texas\",\"Address\":\"Dallas, Texas, United States\",\"City\":\"Dallas\",\"Admin2\":\"Dallas County\",\"Admin1\":\"Texas\",\"Country\":\"United States\",\"CountryCode\":\"US\",\"IATA\":\"DFW\",\"Geohash\":\"9vg4mpgx1hfp\",\"Verified\":true,\"HighConfidence\":true,\"CurrentLocation\":false,\"Latitude\":32.78305816650391,\"Longitude\":-96.80667114257812,\"ReferenceDatum\":\"WGS84\",\"TimeZone\":\"America/Chicago\",\"Radius\":22,\"BoundingBox\":{\"MinLat\":32.61321640014648,\"MaxLat\":33.0237922668457,\"MinLon\":-97.00048065185547,\"MaxLon\":-96.4637222290039},\"Links\":[{\"Label\":\"Wikipedia\",\"URL\":\"http://en.wikipedia.org/wiki/Dallas\"}],\"TypeID\":5,\"SourceID\":2,\"RecordID\":4684888},\"Units\":\"US\"}]}", "conversation"=>{}}
    end
end