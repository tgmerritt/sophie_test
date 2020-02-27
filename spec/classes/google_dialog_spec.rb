require 'rails_helper'

RSpec.describe GoogleDialog do
    before(:each) do
        sc = class_double(Google::Cloud::Dialogflow::Sessions).
        as_stubbed_const(:transfer_nested_constants => true)
        allow(sc).to receive(:new) { OpenStruct.new }
        @gd = GoogleDialog.new(nil, "Hello", "cc5655bc-2221-41fa-b956-cb0ab0929a5e")
        allow(@gd).to receive(:return_new_session) { "blah" }
    end

    it "adds parameters and context to the response" do
        allow(@gd).to receive(:send_query_to_dialogflow).with("blah") { mock_res }
        res = @gd.query_dialogflow
        expect(res[:matchedContext]).to eq ["projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/jpdemoconversation-kiohre.pet-chosen", "projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/__mega_agent_context__"]

        expect(res[:conversationPayload]).to eq ({"pets"=>"猫"})
    end

    it "transforms date and time from ISO-8601" do 
        allow(@gd).to receive(:send_query_to_dialogflow).with("blah") { mock_res }
        res = @gd.parse_fulfillment_text(jp_mock_with_date_and_time)
        expect(res).to eq "<speak>かしこまりました。<say-as interpret-as=\"date\">2020-03-03</say-as>の<say-as interpret-as=\"time\">16:05</say-as>でよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>"

        res = @gd.parse_fulfillment_text(jp_mock_without_date_and_time)
        expect(res).to eq "かしこまりました。2020-03-03T12:00:00-06:00の16:05:00でよろしいですね。空き状況を確認します。しばらくお待ち下さい。"
    end

    def mock_res
        {"queryText"=>"ねこ", "parameters"=>{"pets"=>"猫"}, "allRequiredParamsPresent"=>true, "fulfillmentText"=>"なるほど、猫が好きなんですか。そっか。私も猫が好きです。", "fulfillmentMessages"=>[{"text"=>{"text"=>["なるほど、猫が好きなんですか。そっか。私も猫が好きです。"]}}], "outputContexts"=>[{"name"=>"projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/jpdemoconversation-kiohre.pet-chosen", "lifespanCount"=>5, "parameters"=>{"pets"=>"猫", "pets.original"=>"ねこ"}}, {"name"=>"projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/__mega_agent_context__", "lifespanCount"=>2, "parameters"=>{"pets"=>"猫", "__most_recent_agent_ids__"=>["cc5655bc-2221-41fa-b956-cb0ab0929a5e", "cc5655bc-2221-41fa-b956-cb0ab0929a5e"], "pets.original"=>"ねこ"}}], "intent"=>{"name"=>"projects/jpdemoconversation-kiohre/agent/intents/f32c1db0-fb20-4b9d-a64b-73dee7d5473a", "displayName"=>"jpdemo.conversation.pet-chosen"}, "intentDetectionConfidence"=>1, "languageCode"=>"ja"}
    end

    def jp_mock_with_date_and_time
        "<speak>かしこまりました。<say-as interpret-as=\"date\">2020-03-03T12:00:00-06:00</say-as>の<say-as interpret-as=\"time\">16:05:00</say-as>でよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>"
    end

    def jp_mock_without_date_and_time
        "かしこまりました。2020-03-03T12:00:00-06:00の16:05:00でよろしいですね。空き状況を確認します。しばらくお待ち下さい。"
    end
end


