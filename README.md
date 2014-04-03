# MaxMind Proxy Detection (unofficial)

[![Gem Version](https://badge.fury.io/rb/maxmind_proxy_detection.png)](http://badge.fury.io/rb/maxmind_proxy_detection)
[![Test Coverage](https://codeclimate.com/github/eric-smartlove/maxmind_proxy_detection/coverage.png)](https://codeclimate.com/github/eric-smartlove/maxmind_proxy_detection)
[![Code Climate](https://codeclimate.com/github/eric-smartlove/maxmind_proxy_detection.png)](https://codeclimate.com/github/eric-smartlove/maxmind_proxy_detection)

Wrapper for MaxMind's Proxy Detection service (https://www.maxmind.com/en/proxy)

For minFraud, see this other gem: https://rubygems.org/gems/maxmind

## Installation

Requires ruby 1.9.x

Not tested with ruby 2.x

## Usage

    MaxmindProxyDetection.license_key = 'your_license_key'

    # Returns a float between 0.0 and 4.0
    proxy_score = MaxmindProxyDetection.score("127.0.0.1")

Note that, apparently, when Maxmind service is queried about the same ip several times, only one call is spent.
