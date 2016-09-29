require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])
Dotenv.load if ENV['RACK_ENV'] == 'development'

puts "EMAILS_TO_NOTIFY: #{ENV['EMAILS_TO_NOTIFY'].inspect}"
run lambda { |env| [200, {"Content-Type" => "text/plain"}, ["Hello. The time is #{Time.now}"]] }
