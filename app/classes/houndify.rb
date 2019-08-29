class Houndify
  require 'base64'
  require 'openssl'

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
      "UserID" => userID
      # "Latitude" => 37.388309, 
      # "Longitude" => -121.973968
    }
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
      return JSON.load(response.body)
    rescue
      return { "Error": response }
    end
  end
end