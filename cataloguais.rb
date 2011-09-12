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
  # get the fields into a global array
  set :fields, []
  settings.field_count.times do |i|
    settings.fields << settings.send("field#{i}")
  end
end

get '/' do
  haml :index
end

post '/new/' do
  Item.create(params[:item])
  flash[:notice] = "Item successfully added."
  redirect '/'
end

class Object::String
  # robotize turns a string into something that is a valid hash form,
  # all lower case and with an _ instead of spaces
  def robotize
    return self.downcase.gsub(/\s/, '_')
  end
end

class Item
  include MongoMapper::Document

  # set up the schema for the item
  settings.fields.each do |field|
    key :"#{field.robotize}", String
  end

  # create aliases, so fields can be accessed
  # either as `item.title` or `item.field0`
  settings.fields.each_with_index do |field, i|
    alias :"field#{i}" :"#{field.robotize}"
  end

  # Item.fields returns an array of field names
  def self.fields
    self.keys.keys[1..-1]
  end
  
end
