# frozen_string_literal: true

class SpeaksController < ApplicationController
  # GET /speaks
  # GET /speaks.json
  def index; end

  # POST /speaks
  # POST /speaks.json
  def create
    Speak.new(params).send_unsolicited_response
    render :index
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def speak_params
    params.fetch(:speak, {})
  end
end
