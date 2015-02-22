require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Load this gem (required to run "ruby -I test ...")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'maxmind_proxy_detection'

describe MaxmindProxyDetection do

  before do
    Excon.defaults[:mock] = true
  end

  describe '#available?' do
    before do
      MaxmindProxyDetection.instance_variable_get(:@license_key).must_be_nil
    end

    it 'returns false if no license_key' do
      MaxmindProxyDetection.available?.must_equal false
    end

    it 'returns false if blank license_key' do
      MaxmindProxyDetection.license_key = ''
      MaxmindProxyDetection.available?.must_equal false
    end

    it 'returns true if license_key' do
      MaxmindProxyDetection.license_key = 'any_license_key'
      MaxmindProxyDetection.available?.must_equal true
    end

    after do
      MaxmindProxyDetection.license_key = nil
    end
  end

  describe '#score' do

    # Check that #score calls #request with right parameter
    it 'makes the request with given IP' do
      Excon.stub(
          {body:  'i=any_ip&l=any_license_key'},
          status: 200,
          body:   'proxyScore=1.0'
      )
      MaxmindProxyDetection.license_key = 'any_license_key'
      MaxmindProxyDetection.score('any_ip').must_equal 1.0
    end

    it 'raises if status is not 200' do
      Excon.stub({}, status: 201, body: 'proxyScore=1.0')

      exception = ->{MaxmindProxyDetection.score('any_ip')}.must_raise RuntimeError
      exception.message.must_equal 'Request to Maxmind Proxy Detection service failed'
    end

    it 'raises if service returns an error' do
      Excon.stub({}, status: 200, body: 'err=any_error')

      exception =  ->{MaxmindProxyDetection.score('any_ip')}.must_raise RuntimeError
      exception.message.must_equal 'Error returned by Maxmind Proxy Detection service'
    end

    it 'returns the proxy score returned by the service' do
      Excon.stub({}, status: 200, body: 'proxyScore=1.0')

      MaxmindProxyDetection.score('any_ip').must_equal 1.0
    end

    it 'returns nil if service returns a blank proxy score' do
      Excon.stub({}, status: 200, body: 'proxyScore=')

      MaxmindProxyDetection.score('any_ip').must_be_nil
    end

    it 'raises if service returns an unknown response' do
      Excon.stub({}, status: 200, body: 'unkownKey=1.0')

      exception =  ->{MaxmindProxyDetection.score('any_ip')}.must_raise RuntimeError
      exception.message.must_equal 'Unknown response from Maxmind Proxy Detection service'
    end
  end

  describe '#request' do

    it 'makes the right request to the service' do
      Excon.stub(
          {
              method:  :post,
              host:    'minfraud.maxmind.com',
              path:    '/app/ipauth_http',
              body:    'i=any_ip&l=any_license_key',
              headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
          },
          status: 200,
          body:   'proxyScore=1.0'
      )
      MaxmindProxyDetection.license_key = 'any_license_key'
      response = MaxmindProxyDetection.send(:request, 'any_ip')
      response.body.must_equal 'proxyScore=1.0'
    end
  end

  after do
    Excon.stubs.clear
  end
end

# Check that Maxmind service has the expected behaviour
# Set MAXMIND_PROXY_DETECTION_LICENSE_KEY_FOR_TESTS to an empty value to run tests that don't require a valid license.
describe 'Maxmind service' do

  before do
    unless ENV['MAXMIND_PROXY_DETECTION_LICENSE_KEY_FOR_TESTS']
      skip ('This test needs MAXMIND_PROXY_DETECTION_LICENSE_KEY_FOR_TESTS to be set')
    end
    MaxmindProxyDetection.license_key = ENV['MAXMIND_PROXY_DETECTION_LICENSE_KEY_FOR_TESTS']
  end

  # Test that service use the expected format for error
  it 'returns an error with err key' do
    # Provoke an error by making the request without a license
    MaxmindProxyDetection.license_key = nil

    response = MaxmindProxyDetection.send(:request, 'any_ip')
    response.status.must_equal 200
    response.body.must_equal 'err=LICENSE_REQUIRED'
  end

  it 'returns a score with a proxyScore key' do
    skip  unless MaxmindProxyDetection.available?
    response = MaxmindProxyDetection.send(:request, '127.0.0.1')
    response.status.must_equal 200
    response.body.must_equal 'proxyScore=0.00'
  end

  it 'returns a score with empty value if ip is invalid' do
    skip  unless MaxmindProxyDetection.available?
    response = MaxmindProxyDetection.send(:request, 'invalid_ip')
    response.status.must_equal 200
    response.body.must_equal 'proxyScore='
  end

  after do
    MaxmindProxyDetection.license_key = nil
  end
end
