# frozen_string_literal: true

class Lingmo < ApplicationRecord
  after_initialize :get_token unless Rails.env.test?
  include HTTParty

  def get_token
    response = HTTParty.get("http://live.lingmo-api.com/v1/token/get/#{Rails.application.secrets.lingmo_api_key}")
    update_attributes(token: response['Token'], owner: response['Owner'], lingmo_id: response['ID'], expiration_timestamp: Time.at(response['ExpiresAtTimestamp']), request_endpoint: response['RequestEndPoint'])
  end

  def expired?
    # If no token exists we need to fetch it
    # Return true if the timestamp for the token is more than 2 hours old
    if expiration_timestamp.nil? || Time.now > (expiration_timestamp + 2.hours)
      Lingmo.delete_all
      true
    else
      false
    end
  end

  # Source and Target are both language codes
  # http://live.lingmo-api.com/support/lingmo-translation-languages.html
  # fr-FR = French
  # en-US = English
  def translate(_source, _target, _text)
    get_token if expired?

    headers = {
      "Authorization": token,
      "Content-Type": 'text/plain'
    }
    options = {
      body: _text,
      headers: headers,
      query: { "sourceLang": _source, "targetLang": _target }
    }
    response = HTTParty.post('http://live.lingmo-api.com/v1/translation/dotranslate', options)

    response['ResponseText']
  end
end
