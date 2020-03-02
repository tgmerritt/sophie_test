# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleDialog do
  before(:each) do
    sc = class_double(Google::Cloud::Dialogflow::Sessions)
         .as_stubbed_const(transfer_nested_constants: true)
    allow(sc).to receive(:new) { OpenStruct.new }
    @gd = GoogleDialog.new(nil, 'Hello', 'cc5655bc-2221-41fa-b956-cb0ab0929a5e')
    allow(@gd).to receive(:return_new_session) { 'blah' }
  end

  it 'adds parameters and context to the response' do
    allow(@gd).to receive(:send_query_to_dialogflow).with('blah') { mock_res }
    res = @gd.query_dialogflow
    expect(res[:matchedContext]).to eq ''

    expect(res[:conversationPayload]).to eq '{context: ["pet-chosen"], parameters: {"pets"=>"猫"}}'
  end

  it 'builds instructions with html' do
    allow(@gd).to receive(:send_query_to_dialogflow).with('blah') { jp_mock_with_html }
    res = @gd.query_dialogflow
    answer = JSON.parse(res[:answer])
    expect(answer['answer']).to eq '承知致しました。席の空き状況はこちらです。ご希望の席をおっしゃって下さい。'
    expect(answer['instructions']['displayHtml']).to eq ({ 'html' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />' })
    expect(answer['instructions']['expressionEvent']).to eq [{ 'expression' => 'smile', 'start' => 1, 'value' => 1, 'duration' => 10 }]
    expect(answer['instructions']['emotionalTone']).to eq [{ 'tone' => 'sadness', 'start' => 0.1, 'value' => 1, 'additive' => false, 'duration' => 10 }]
  end

  it 'transforms date and time from ISO-8601' do
    allow(@gd).to receive(:send_query_to_dialogflow).with('blah') { mock_res }
    res = @gd.parse_fulfillment_text(jp_mock_with_date_and_time)
    expect(res).to eq '<speak>かしこまりました。<say-as interpret-as="date">2020-03-03</say-as>の<say-as interpret-as="time">16:05</say-as>でよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>'

    res = @gd.parse_fulfillment_text(jp_mock_without_date_and_time)
    expect(res).to eq 'かしこまりました。2020-03-03T12:00:00-06:00の16:05:00でよろしいですね。空き状況を確認します。しばらくお待ち下さい。'

    res = @gd.parse_fulfillment_text(jp_mock_with_speak_but_no_say_as)
    expect(res).to eq '<speak>かしこまりました。のでよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>'

    # Test pending a support request to Dialogflow regarding a bogus time value
    # res = @gd.parse_fulfillment_text(jp_mock_with_time_zone)
    # expect(res).to eq '<speak>かしこまりました。<say-as interpret-as="date">2020-03-10</say-as>の<say-as interpret-as="time">15:00:00</say-as>でよろしいですね。何名で乗車されますか？</speak>'
  end

  it 'returns a <speak> string' do
  end

  def mock_res
    { 'queryText' => 'ねこ', 'parameters' => { 'pets' => '猫' }, 'allRequiredParamsPresent' => true, 'fulfillmentText' => 'なるほど、猫が好きなんですか。そっか。私も猫が好きです。', 'fulfillmentMessages' => [{ 'text' => { 'text' => ['なるほど、猫が好きなんですか。そっか。私も猫が好きです。'] } }], 'outputContexts' => [{ 'name' => 'projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/jpdemoconversation-kiohre.pet-chosen', 'lifespanCount' => 5, 'parameters' => { 'pets' => '猫', 'pets.original' => 'ねこ' } }, { 'name' => 'projects/newagent-gjetnk/agent/sessions/avatarSessionId/contexts/__mega_agent_context__', 'lifespanCount' => 2, 'parameters' => { 'pets' => '猫', '__most_recent_agent_ids__' => %w[cc5655bc-2221-41fa-b956-cb0ab0929a5e cc5655bc-2221-41fa-b956-cb0ab0929a5e], 'pets.original' => 'ねこ' } }], 'intent' => { 'name' => 'projects/jpdemoconversation-kiohre/agent/intents/f32c1db0-fb20-4b9d-a64b-73dee7d5473a', 'displayName' => 'jpdemo.conversation.pet-chosen' }, 'intentDetectionConfidence' => 1, 'languageCode' => 'ja' }
  end

  def jp_mock_with_date_and_time
    '<speak>かしこまりました。<say-as interpret-as="date">2020-03-03T12:00:00-06:00</say-as>の<say-as interpret-as="time">16:05:00</say-as>でよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>'
  end

  def jp_mock_without_date_and_time
    'かしこまりました。2020-03-03T12:00:00-06:00の16:05:00でよろしいですね。空き状況を確認します。しばらくお待ち下さい。'
  end

  def jp_mock_with_time_zone
    # Looks like Dialogflow may have a bug, despite verbally speaking "午後３時" the system returns 3 am
    '<speak>かしこまりました。<say-as interpret-as="date">2020-03-10T12:00:00+09:00</say-as>の<say-as interpret-as="time">2020-03-03T03:00:00+09:00</say-as>でよろしいですね。何名で乗車されますか？</speak>'
  end

  def jp_mock_with_speak_but_no_say_as
    '<speak>かしこまりました。のでよろしいですね。空き状況を確認します。しばらくお待ち下さい。</speak>'
  end

  def jp_mock_with_html
    {
      'queryText' => 'はい',
      'action' => 'jpdemoconversationdestination.jpdemoconversationdestination-yes',
      'parameters' => {
        'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
        'emotionalTone' => '[{"tone":"sadness","start":0.1, "value":1,"additive":false,"duration":10}]',
        'expressionEvent' => '[{"expression":"smile","start":1, "value":1,"duration":10}]'
      },
      'allRequiredParamsPresent' => true,
      'fulfillmentText' => '承知致しました。席の空き状況はこちらです。ご希望の席をおっしゃって下さい。',
      'fulfillmentMessages' => [
        {
          'text' => {
            'text' => [
              '承知致しました。席の空き状況はこちらです。ご希望の席をおっしゃって下さい。'
            ]
          }
        }
      ],
      'outputContexts' => [
        {
          'name' => 'projects/jpdemoconversation-kiohre/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/jp-train-demo',
          'lifespanCount' => 5,
          'parameters' => {
            'date-period' => '',
            'time-period.original' => '',
            'date.original' => '',
            'destination_station' => '新大阪駅',
            'emotionalTone' => '[{"tone":"sadness","start":0.1, "value":1,"additive":false,"duration":10}]',
            'time' => '2020-02-28T08:00:00-06:00',
            'date' => '2021-02-12T12:00:00-06:00',
            'number' => 2,
            'time-period' => '',
            'emotionalTone.original' => '',
            'displayHtml.original' => '',
            'destination_station.original' => '大阪',
            'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
            'date-period.original' => '',
            'number.original' => '２',
            'time.original' => '',
            'originating_station.original' => '',
            'people.original' => '',
            'originating_station' => '博多駅',
            'people' => 2
          }
        },
        {
          'name' => 'projects/jpdemoconversation-kiohre/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/jpdemoconversationdestination-followup',
          'lifespanCount' => 5,
          'parameters' => {
            'people.original' => '',
            'originating_station.original' => '',
            'originating_station' => '博多駅',
            'people' => 2,
            'date.original' => '',
            'destination_station' => '新大阪駅',
            'time' => '2020-02-28T08:00:00-06:00',
            'date' => '2021-02-12T12:00:00-06:00',
            'displayHtml.original' => '',
            'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
            'destination_station.original' => '大阪',
            'time.original' => ''
          }
        },
        {
          'name' => 'projects/jpdemoconversation-kiohre/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/passengers_selected',
          'lifespanCount' => 4,
          'parameters' => {
            'displayHtml.original' => '',
            'destination_station.original' => '大阪',
            'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
            'number.original' => '２',
            'time.original' => '',
            'people.original' => '',
            'originating_station.original' => '',
            'originating_station' => '博多駅',
            'people' => 2,
            'date.original' => '',
            'destination_station' => '新大阪駅',
            'time' => '2020-02-28T08:00:00-06:00',
            'date' => '2021-02-12T12:00:00-06:00',
            'number' => 2
          }
        },
        {
          'name' => 'projects/jpdemoconversation-kiohre/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/date_and_time_selected',
          'lifespanCount' => 4,
          'parameters' => {
            'originating_station.original' => '',
            'people.original' => '',
            'originating_station' => '博多駅',
            'people' => 2,
            'date-period' => '',
            'time-period.original' => '',
            'date.original' => '',
            'destination_station' => '新大阪駅',
            'emotionalTone' => '[{"tone":"sadness","start":0.1, "value":1,"additive":false,"duration":10}]',
            'time' => '2020-02-28T08:00:00-06:00',
            'date' => '2021-02-12T12:00:00-06:00',
            'emotionalTone.original' => '',
            'time-period' => '',
            'number' => 2,
            'displayHtml.original' => '',
            'destination_station.original' => '大阪',
            'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
            'date-period.original' => '',
            'number.original' => '２',
            'time.original' => ''
          }
        },
        {
          'name' => 'projects/jpdemoconversation-kiohre/agent/sessions/806544e0-1d27-3cf2-377d-2222953ffd0e/contexts/destination_selected',
          'lifespanCount' => 1,
          'parameters' => {
            'date.original' => '',
            'destination_station' => '新大阪駅',
            'time' => '2020-02-28T08:00:00-06:00',
            'date' => '2021-02-12T12:00:00-06:00',
            'displayHtml.original' => '',
            'displayHtml' => '<img src="assets/reserve_seat_list_select.png" style="margin-top: 3.5em;max-width: 300px;margin-right: 6em;" />',
            'destination_station.original' => '大阪',
            'time.original' => '',
            'people.original' => '',
            'originating_station.original' => '',
            'people' => 2,
            'originating_station' => '博多駅'
          }
        }
      ],
      'intent' => {
        'name' => 'projects/jpdemoconversation-kiohre/agent/intents/62f9eff4-5933-47f2-94a3-8012073ffc01',
        'displayName' => 'jpdemo.conversation.destination - yes'
      },
      'intentDetectionConfidence' => 1,
      'languageCode' => 'ja'
    }
  end

  def jp_mock_for_weather; end
end
