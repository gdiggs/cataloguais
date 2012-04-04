ENV['RACK_ENV'] = 'test'

require_relative '../cataloguais'
require 'shoulda-context'
require 'test/unit'
require 'rack/test'

Turn.config do |c|
 c.format = :dotted
 c.trace = true
end

