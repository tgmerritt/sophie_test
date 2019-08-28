class Conversation < ApplicationRecord
    require 'jwt'
    include HTTParty

    def authenticate_to_faceme(params)
        response = HTTParty.post('https://dal-admin.faceme.com/api/v1/clients/access/tokens', {
            headers: {"Content-Type": "application/jwt", "workspace": Rails.application.secrets.workspace_id},
            body: encode_payload(params).to_s
        })
        
        # puts response.body, response.code, response.message, response.headers.inspect

        # It's a dirty hack - so just drop everything in the DB and add it each time we hit - that way it's always Conversation.first when we want it - NO this isn't a best practice
        Conversation.delete_all
        Conversation.create(token: response["token"])
    end

    def create_location_obj(params)
        {latitude: params[:latitude], longitude: params[:longitude]}
    end

    def encode_payload(params)
        payload = {
            'sid' => SecureRandom.uuid, # Generate a random conversation ID each time we boot up a digital human convo
            'fm-custom-data' => JSON.generate(create_location_obj(params)),  # Documentation isn't clear on this at all
            'fm-workspace' => Rails.application.secrets.fm_workspace.to_s,
        }

        hmac_secret = Rails.application.secrets.customer_jwt_secret

        token = JWT.encode payload, hmac_secret, 'HS256'
    end
end
