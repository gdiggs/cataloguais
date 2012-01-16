#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'
require 'csv'

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

configure :development do
  ENV['ADMIN_PASSWORD'] = 'test'
end

configure do
  config_file 'settings.yml'
  MongoMapper.database = settings.database unless @db_name
  # get the fields into a global array
  set :field_count, settings.fields.count

  # set the input width based on the number of fields
  set :item_width, 840 / settings.field_count
  
  # robotize the sort order
  set :sort_order, settings.sort_order.collect {|sort| sort.robotize}
end

before do
  if ENV['ADMIN_PASSWORD'].nil?
    warn "!!! Admin password not set - editing will be enabled by default"
    session['editing_enabled'] = true
  end
end

before /(new|update|delete|import)/ do
  unless session['editing_enabled']
    data = { :status => 'error', :message => 'Hey, Mike! Editing must be enabled to do that!' }.to_json
    halt data
  end
end

get '/' do
  @sort = if params[:sort]
            [params[:sort]] + (settings.sort_order - [params[:sort]])
          else
            settings.sort_order
          end
  @items = Item.all(:order => @sort).select { |item| item.to_s.downcase.include? params[:search].to_s.downcase }
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

post '/import/' do
  data = CSV.parse(params[:file][:tempfile].read)
  headers = data.shift

  data.each do |row|
    item = Item.new
    headers.each_with_index do |attr, i|
      item.write_attribute(attr.robotize, row[i])
    end
    item.save
  end
  redirect '/'
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

get '/graphs/' do
  get_occurrences
  get_graph_urls
  haml :graphs
end

# render the row of the table for a given partial
def item_table_row(item)
  @item = item
  haml :_item, :layout => false
end

# Get the occurrences of values for each field on Item
def get_occurrences
  @occurrences = {}

  settings.fields.each { |field| @occurrences[field] = {} }

  settings.fields.each do |field|
    Item.all.each do |item|
      value = item.send(field.robotize)
      if @occurrences[field][value]
        @occurrences[field][value] += 1
      else
        @occurrences[field][value] = 1
      end
    end

    others = 0
    @occurrences[field].each do |key, value|
      if value == 1
        @occurrences[field].delete(key)
        others += 1
      end
    end
    # can't create new keys in a hash while iterating through it, so we have to do it after the loop
    @occurrences[field]["Other"] = others unless others == 0
  end
end

# Get the graph urls, given the occurrences already been set
def get_graph_urls
  @graph_urls = {}
  @occurrences.each do |label, data_set|
    img_src = Gchart.pie(:labels => data_set.keys, :data => data_set.values, :size => '600x400', :bg => '2f2f2f')

    # Request length must be less than 2048, otherwise it will fail
    if img_src.length < 2048
      @graph_urls[label] = img_src
    else
      warn "Request length for '#{label}' graph is too long. Skipping."
    end
  end
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
