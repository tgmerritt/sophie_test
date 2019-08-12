class FmauthsController < ApplicationController
    protect_from_forgery with: :null_session

    def create
        token = Conversation.first.token
        api_key = Rails.application.secrets.fm_api_key
        render json: {apiKey: api_key, token: token} 
    end
end
