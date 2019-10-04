#!/bin/bash
cd /app
bundle
bundle exec ruby file-export.rb
echo "Finished file export"
