ENV['RACK_ENV'] = 'test'

require_relative '../cataloguais'
require 'test/unit'
require 'shoulda-context'
require 'rack/test'
