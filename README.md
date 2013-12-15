# MaxMind Proxy Detection

Wrapper for MaxMind's Proxy Detection service

## Installation

Requires ruby 1.9.x

Not tested with ruby 2.x

## Usage

    MaxmindProxyDetection.license_key = 'your_license_key'

    # Returns a float between 0.0 and 4.0
    proxy_score = MaxmindProxyDetection.score("127.0.0.1")
