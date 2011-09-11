require 'rubygems'
require 'sinatra'
require 'tilt'

# logging
FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

require 'cataloguais'
run Sinatra::Application
