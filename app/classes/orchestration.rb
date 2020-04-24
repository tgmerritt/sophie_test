# frozen_string_literal: true

class Orchestration
  attr_accessor :query, :conversation_state, :location, :partner, :response

  def initialize(params, partner)
    @query = params['fm-question'] # string, query from the STT engine of UneeQ
    @conversation_state = params['fm-conversation'].blank? ? nil : params['fm-conversation'] # Maintain conversation state between utterances
    @location = params['fm-custom-data'].blank? ? {} : JSON.parse(params['fm-custom-data'])
    @partner = partner # string, the name of the partner company we reach out to
    @avatar_session_id = params['fm-avatar'].nil? ? nil : params['fm-avatar']['avatarSessionId']
    @response = nil
  end

  def orchestrate
    case @partner
    when 'Houndify'
      Houndify.new.query_houndify(@location, @conversation_state, @query)
    when 'Dialogflow'
      GoogleDialog.new(@conversation_state, @query, @avatar_session_id).query_dialogflow
    end
  end
end
