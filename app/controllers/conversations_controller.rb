class ConversationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def index
    # Create a single-use token - this is what causes the digital human to display in the first place
    Conversation.new.authenticate_to_faceme(params)

    # Grabs the exisitng single-use token from the database (which we just created) supplies it to the front-end
    # There are other ways to do this - you could use AJAX directly from the front-end and return some values stored in a database somewhere, or grab a file
    # from an online bucket like S3 which contains the parameters - single use has to be instantiated every time, which makes my method more palatable for Rails

    @token = Conversation.first.token
  end

  def create
    # Change the second parameter to another NLP provider in order to query against that provider
    # You could also implement a custom cascading check against multiple NLP providers.
    # params[:nlp] value needs to be set by UneeQ in the 3rd Party config under the workspace
    Conversation.first.update_session(params)
    response = Orchestration.new(params, params[:nlp]).orchestrate
    render json: response
  end
end
