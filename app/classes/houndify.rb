class Houndify
  require 'base64'
  require 'openssl'
  require 'json'

  HOUND_SERVER="https://api.houndify.com"
  TEXT_ENDPOINT="/v1/text"
  VOICE_ENDPOINT="/v1/audio"  
  VERSION="1.2.5"

  attr_accessor :hound_request_info, :location

  def initialize(clientID = nil, clientKey = nil, userID = "test_user", hostname = nil, proxyHost = nil, proxyPort = nil, proxyHeaders = nil)
    @clientID = Rails.application.secrets.houndify_client_id  
    @clientKey = Base64.urlsafe_decode64(Rails.application.secrets.houndify_client_secret) 
    @userID = userID
    @hostname = hostname
    @proxyHost = proxyHost
    @proxyPort = proxyPort
    @proxyHeaders = proxyHeaders
    @gzip = true # Net::HTTP takes care of unzipping compressed responses, so we should always use them to save bandwidth

    @hound_request_info = {
      "ClientID" => Rails.application.secrets.houndify_client_id, 
      "UserID" => userID,
      "StoredGlobalPagesToMatch" => ["Uneeq"]
      # "Latitude" => 37.388309, 
      # "Longitude" => -121.973968
    }
  end

  def query_houndify(location, state, query)
    hound = Houndify.new
    hound.set_conversation_state(JSON.parse(state)) if state # UneeQ returns conversation state to us stringified, so we have to unravel that and make it a JSON object again
    if !location["latitude"].blank? && !location["longitude"].blank?
        hound.set_location(location["latitude"].to_f,  location["longitude"].to_f)
    end
    response = hound.query(query)
    setup_houndify_json(response)
  end

  def set_hound_request_info(key, value)
    """
    There are various fields in the hound_request_info object that can
    be set to help the server provide the best experience for the client.
    Refer to the Houndify documentation to see what fields are available
    and set them through this method before starting a request
    """
    @hound_request_info[key] = value
  end

  def remove_hound_request_info(key)
    """
    Remove request info field through this method before starting a request
    """
    @hound_request_info.delete(key)
  end

  def set_location(latitude, longitude)
    """
    Many domains make use of the client location information to provide
    relevant results.  This method can be called to provide this information
    to the server before starting the request.

    latitude and longitude are floats (not string)
    """
    @hound_request_info["Latitude"] = latitude
    @hound_request_info["Longitude"] = longitude
    @hound_request_info["PositionTime"] = Time.now.to_i
  end

  def set_conversation_state(conversation_state)
    @hound_request_info["ConversationState"] = conversation_state
    if conversation_state.has_key?("ConversationStateTime")
      @hound_request_info["ConversationStateTime"] = conversation_state["ConversationStateTime"]
    end
  end

  def generate_headers(requestInfo)    
      requestID = SecureRandom.uuid
      if requestInfo.has_key?("RequestID")
        requestID = requestInfo["RequestID"]
      end

      timestamp = (Time.now.to_i).to_s
      if requestInfo.has_key?("TimeStamp")
        timestamp = str(requestInfo["TimeStamp"])
      end

      hound_request_auth = @userID + ";" + requestID
      digest = OpenSSL::Digest.new('sha256')
      h = OpenSSL::HMAC.digest(digest, @clientKey, (hound_request_auth + timestamp).to_s)
      signature = Base64.urlsafe_encode64(h)
      hound_client_auth = @clientID + ";" + timestamp + ";" + signature

      headers = {
        "Hound-Request-Info" => requestInfo.to_json,
        "Hound-Request-Authentication" => hound_request_auth,
        "Hound-Client-Authentication" => hound_client_auth
      }

      if requestInfo.has_key?("InputLanguageEnglishName")
          headers["Hound-Input-Language-English-Name"] = requestInfo["InputLanguageEnglishName"]
      end
      if requestInfo.has_key?("InputLanguageIETFTag")
          headers["Hound-Input-Language-IETF-Tag"] = requestInfo["InputLanguageIETFTag"]
      end

      return headers
  end

  def query(text_query)
    """
    Make a text query to Hound.

    query is the string of the query
    """
    headers = generate_headers(@hound_request_info)
    if @gzip
      headers["Hound-Response-Accept-Encoding"] = "gzip, deflate"
    end

    # puts "Houndify Headers before Query"
    # puts headers
    # When would we need a proxy?
    # if self.proxyHost
    #   conn = http.client.HTTPSConnection(self.proxyHost, self.proxyPort)
    #   conn.set_tunnel(self.hostname, headers = self.proxyHeaders) 
    # else
    #   conn = http.client.HTTPSConnection(self.hostname)
    # end

    uri = "#{HOUND_SERVER}#{TEXT_ENDPOINT}?query="
    escaped_query = CGI::escape(text_query)
    response = HTTParty.get(uri+escaped_query, {
      headers: headers
    })

    begin
      # puts response.body
      return JSON.load(response.body)
    rescue
      return { "Error": response }
    end
  end

  def setup_houndify_json(response)
    handle_houndify_daily_limit(response)
  end

  def handle_houndify_daily_limit(response)
    @response = response
    if @response[:Error]
        create_json_to_send("Sorry, I cannot answer that right now", nil, houndify_configure_expression)
    else
        text = @response["AllResults"][0]["WrittenResponseLong"]
        create_json_to_send(text, houndify_combined_html(houndify_html, houndify_html_assets), houndify_configure_expression)
    end
  end

  def houndify_combined_html(html, html_assets)
    if html.nil?
        combined_html = nil
    else
        css = html_assets["CSS"].gsub(/\"/, '\'')
        js = html_assets["JS"].gsub(/\"/, '\'')
        combined_html = css + js + html
        combined_html.gsub!(/[\r\n]+/, ' ')
    end
  end

  def houndify_html_assets
      if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["HTMLHead"]
          @response["AllResults"][0]["HTMLData"]["HTMLHead"]
      else
          nil
      end
  end

  def houndify_html
      if @response["AllResults"][0]["HTMLData"] && @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
          @response["AllResults"][0]["HTMLData"]["SmallScreenHTML"]
      else
          nil
      end
  end

  def houndify_configure_expression
    if @response["AllResults"] && @response["AllResults"][0]["Emotion"] && !@response["AllResults"][0]["Emotion"].empty?
      # This is a gross hack of the Houndify "Emotion" property - they only support strings, so I've entered a comma-separated string, parsed to Hash, and parsed values to proper types
      # Yuck...
      emotion_hash = Hash[*@response["AllResults"][0]["Emotion"].split(',')]
      emotion_hash["value"] = emotion_hash["value"].to_f
      emotion_hash["start"] = emotion_hash["start"].to_i
      emotion_hash["duration"] = emotion_hash["duration"].to_i
      emotion_hash
    else
      {}
    end
  end

  def houndify_conversation_state
      if @response["AllResults"] && @response["AllResults"][0]["ConversationState"]
          generate_json_string(@response["AllResults"][0]["ConversationState"])
      else
          ""
      end
  end

  def generate_json_string(data)
      JSON.generate(data)
  end

  def create_json_to_send(text, html, expression)
      answer_body = {
          "answer": text,
          "instructions": {
              "expressionEvent": [
                expression
              ],
              "emotionalTone": [
                  {
                      "tone": "happiness", # desired emotion in lowerCamelCase
                      "value": 0.5, # number, intensity of the emotion to express between 0.0 and 1.0 
                      "start": 2, # number, in seconds from the beginning of the utterance to display the emotion
                      "duration": 4, # number, duration in seconds this emotion should apply
                      "additive": true, # boolean, whether the emotion should be added to existing emotions (true), or replace existing ones (false)
                      "default": true # boolean, whether this is the default emotion 
                  }
              ],
              "displayHtml": {
                  "html": html
              }
          }
      }

      body = {
          "answer": generate_json_string(answer_body),         
          "matchedContext": "",
          "conversationPayload": houndify_conversation_state,
      }
      return body
  end
end