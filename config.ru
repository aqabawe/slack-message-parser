require 'dotenv/load'
require './auth'
require './bot'
require 'logger'
# Initialize the app and create the API (bot) and Auth objects.
run Rack::Cascade.new [API, Auth]
