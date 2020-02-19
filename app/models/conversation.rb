# frozen_string_literal: true

class Conversation < ApplicationRecord
  require 'jwt'
  include HTTParty

  def authenticate_to_faceme(params)
    response = HTTParty.post("#{Rails.application.secrets.default_hostname}/api/v1/clients/access/tokens",
                             headers: { "Content-Type": 'application/jwt', "workspace": Rails.application.secrets.workspace_id },
                             body: encode_payload(params).to_s)
    # puts response.body, response.code, response.message, response.headers.inspect

    # It's a dirty hack - so just drop everything in the DB and add it each time we hit - that way it's always Conversation.first when we want it - NO this isn't a best practice
    Conversation.delete_all
    Conversation.create(token: response['token'])
  end

  def update_session(params)
    session = JSON.parse(params['fm-avatar'])
    if null_session?
      update(session_id: params['sid'], avatar_session_id: session['avatarSessionId'])
      end
  end

  def null_session?
    return true if avatar_session_id.nil? || session_id.nil?
  end

  def create_location_obj(params)
    { latitude: params[:latitude], longitude: params[:longitude] }
  end

  def encode_payload(params)
    payload = {
      'sid' => SecureRandom.uuid, # Generate a random conversation ID each time we boot up a digital human convo
      'fm-custom-data' => JSON.generate(create_location_obj(params)), # Documentation isn't clear on this at all
      'fm-workspace' => Rails.application.secrets.fm_workspace.to_s
    }

    hmac_secret = Rails.application.secrets.customer_jwt_secret

    token = JWT.encode payload, hmac_secret, 'HS256'
  end
end
