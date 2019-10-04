#!/bin/bash
cd /app
bundle
bundle exec ruby ttl-export.rb
echo "Finished TTL export"
