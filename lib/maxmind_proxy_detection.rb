require 'excon'

module MaxmindProxyDetection
  URL = 'https://minfraud.maxmind.com/app/ipauth_http'

  class << self
    attr_writer :license_key

    def available?
      return true  if @license_key && !@license_key.empty?
      return false
    end

    # Query Maxmind Proxy Detection service with given ip and set license_key.
    # @return [Float, nil] Proxy score from 0.0 to 4.0. Nil if IP is invalid.
    def score(ip)
      response = request(ip)

      raise 'Request to Maxmind Proxy Detection service failed' unless response.status == 200

      # Parse response
      key, value = response.body.split('=')

      # Process response
      case key
        when 'err'
          raise 'Error returned by Maxmind Proxy Detection service'
        when 'proxyScore'
          return value.to_f  if value
          return nil  # According to documentation, response does not contain value if IP is invalid
        else
          raise 'Unknown response from Maxmind Proxy Detection service'
      end
    end

    private
    def request(ip)
      # Maxmind Proxy Detection service accepts query strings (GET) and for posts (POST). We use form post with
      # parameters in body to minimize the chance that license_key is stored in clear by a proxy or a logger.
      return Excon.post(URL,
        body:    URI.encode_www_form(i: ip, l: @license_key),
        headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
      )
    end
  end
end
