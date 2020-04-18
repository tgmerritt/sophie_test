# frozen_string_literal: true

class Speak < ApplicationRecord
  attr_accessor :params

  DEFAULT_HOSTNAME = Rails.application.secrets.default_hostname
  CUSTOMER_JWT_SECRET = Rails.application.secrets.customer_jwt_secret

  def initialize(params)
    @params = params
  end

  def send_unsolicited_response
    puts 'Sending unsolicited response...'
    conversation = Conversation.first
    headers = {
      "Content-Type": 'application/json'
    }

    sessionIdJwt = JWT.encode ({ sessionId: conversation.avatar_session_id }), CUSTOMER_JWT_SECRET, 'HS256'

    body = {
      answer: params['text_to_speak'],
      answerAvatar: JSON.generate(
        "instructions": {
          "expressionEvent": [{
            "expression": 'headPitch',
            "value": 0.5,
            "start": 2,
            "duration": 5
          }],
          "emotionalTone": [{
            "tone": 'happiness',
            "value": 0.5,
            "start": 2,
            "duration": 4,
            "additive": true,
            "default": true
          }],
          "displayHtml": {
            "html": '<h1>TYLER IS THE MAN</h1>'
          }
        }
      ),
      sessionIdJwt: sessionIdJwt
    }

    options = {
      body: JSON.generate(body),
      headers: headers
    }

    response = HTTParty.post("#{DEFAULT_HOSTNAME}/api/v1/avatar/#{conversation.avatar_session_id}/speak",
                             body: JSON.generate(body),
                             headers: headers)
  end
end
