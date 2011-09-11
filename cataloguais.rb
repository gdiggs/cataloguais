#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'

Bundler.require
require "sinatra/config_file"
enable :sessions
use Rack::Flash

configure :production do
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  @db_name = uri.path.gsub(/^\//, '')
  db = conn.db(@db_name)
  MongoMapper.connection = conn
  MongoMapper.database = @db_name
end

configure do
  config_file 'settings.yml'
  MongoMapper.database = settings.database unless @db_name
end

get '/' do
  haml :index
end

post '/new/' do
  puts params[:item]
  Item.create(params[:item])
  flash[:notice] = "Item successfully added."
  redirect '/'
end

class Item
  include MongoMapper::Document

  # set up the schema for the item
  settings.field_count.times do |i|
    key :"field#{i}", String
  end
  
end
