# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def create
    response = WeatherHook.new(params).evaluate
    render json: response
  end

  private

  def webhook_params
    params.fetch(:webhook, {})
  end
end
