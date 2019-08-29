class ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: :create

  def index
    Conversation.new.authenticate_to_faceme(params)

    @token = Conversation.first.token
    @api_key = Rails.application.secrets.fm_api_key
  end

  def create
    # Change the second parameter to another NLP provider in order to query against that provider
    # You could also implement a custom cascading check against multiple NLP providers.
    orchestration = Orchestration.new(params, "Houndify")
    response = orchestration.orchestrate
    render json: response
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation
      @conversation = Conversation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conversation_params
      params.fetch(:conversation, {})
    end
end
