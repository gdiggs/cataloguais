#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'

Bundler.require
require "sinatra/config_file"

configure :production do
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  db = conn.db(uri.path.gsub(/^\//, ''))
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
