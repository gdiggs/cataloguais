#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'

Bundler.require
require "sinatra/config_file"

configure :production do
  # next 4 lines from http://bit.ly/nyu6SD
  uri =  URI.parse(ENV['MONGOHQ_URL'])
  @mongo_connection = Mongo::Connection.from_uri(uri)
  @mongo_db = @mongo_connection.db(uri.path.gsub(/^\//, ''))
  @mongo_db.authenticate(uri.user, uri.password)
end

configure do
  config_file 'settings.yml'
  MongoMapper.database = settings.database
end

get '/' do
  haml :index
end

get '/add_test' do

end

class Item
  include MongoMapper::Document

  # set up the schema for the item
  settings.field_count.times do |i|
    key :"field#{i}", String
  end
  
end
