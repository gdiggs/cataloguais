require 'rubygems'

set :run, false
set :environment, :production

# logging
FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

require 'cataloguais'
run Sinatra::Application
