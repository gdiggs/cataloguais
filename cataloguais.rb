#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'

Bundler.require
require "sinatra/config_file"

enable :sessions

class Object::String
  # robotize turns a string into something that is a valid hash form,
  # all lower case and with an _ instead of non-word characters
  def robotize
    return self.downcase.gsub(/[^a-zA-z0-9]/, '_')
  end
end

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
  set :field_count, settings.fields.count

  # set the input width based on the number of fields
  set :item_width, 840 / settings.field_count
  
  # set the default sort value (defaults to first field)
  if ENV['DEFAULT_SORT']
    raise "ENV['DEFAULT_SORT'] value (#{ENV['DEFAULT_SORT']}) is not in settings.fields" unless settings.fields.include?(ENV['DEFAULT_SORT'])
    set :default_sort, ENV['DEFAULT_SORT'].robotize
  else
    set :default_sort, settings.fields[0].robotize
  end
end

before do
  if ENV['ADMIN_PASSWORD'].nil?
    warn "!!! Admin password not set - editing will be enabled by default"
    session['editing_enabled'] = true
  end
end

before /(new|update|delete)/ do
  unless session['editing_enabled']
    data = { :status => 'error', :message => 'Hey, Mike! Editing must be enabled to do that!' }.to_json
    halt data
  end
end

get '/' do
  @sort = params[:sort] || settings.default_sort
  @items = Item.all(:order => @sort)
  haml :index
end

get '/export/' do
  headers "Content-Disposition" => "attachment;filename=collection_#{Time.now.strftime("%y%m%d%H%M%S")}.csv", "Content-Type" => "application/octet-stream"
  Item.export
end

post '/new/' do
  item = Item.create(params[:item])
  { :status => 'success', :message => 'Item successfully added.', :item_markup => item_table_row(item) }.to_json
end

post '/update/:id' do
  item = Item.find(params[:id])
  item.update_attributes(params[:item])
  { :status => 'success', :message => 'Item successfully updated.', :item_markup => item_table_row(item) }.to_json
end

delete '/delete/:id' do
  Item.find(params[:id]).destroy
  {:status => 'success', :message => 'Item successfully deleted.'}.to_json
end

get '/stylesheet.css' do
  sass :stylesheet
end

post '/login' do
  session['editing_enabled'] = true if ENV['ADMIN_PASSWORD'] && params[:password] == ENV['ADMIN_PASSWORD']
  redirect '/'
end

get '/logout' do
  session['editing_enabled'] = nil
  redirect '/'
end

# render the row of the table for a given partial
def item_table_row(item)
  @item = item
  haml :_item, :layout => false
end

# The Item class holds the data for each catalog entry
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

  # Export CSV data as a string
  # First row is headers, with each Item having a row after
  def self.export
    (self.fields.join(",") + "\n" + Item.all.join("\n")).gsub(/"/, '')
  end

  # Item.fields returns an array of field names
  def self.fields
    self.keys.keys[1..-1]
  end

  def to_s
    Item.fields.collect{ |f| self.send(f) }.join(",")
  end    
  
end
