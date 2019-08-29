class ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: :create

  def index
    # Create a single-use token - this is what causes the digital human to display in the first place
    Conversation.new.authenticate_to_faceme(params)

    # Grabs the exisitng single-use token from the database (which we just created) and a necessary api key from YAML and supplies them to the front-end
    # There are other ways to do this - you could use AJAX directly from the front-end and return some values stored in a database somewhere, or grab a file
    # from an online bucket like S3 which contains the parameters - single use has to be instantiated every time, which makes my method more palatable for Rails

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
