#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'uri'
require 'csv'

Bundler.require
require "sinatra/config_file"
require_relative "extensions/string"

enable :sessions

configure do
  config_file 'settings.yml'

  # require the model(s) before setting up the database
  require_relative "models/item"
  DataMapper.finalize

  settings.fields << 'Created At'

  # set the input width based on the number of fields
  set :item_width, 840 / settings.fields.count
  
  # robotize the sort order
  set :sort_order, settings.sort_order.collect {|sort| sort.robotize}

  # initialize the graph urls on startup
  set :graph_urls, {}

end

configure :production do
  DataMapper::Logger.new($stdout, :info)
end

configure :test do
  ENV['DATABASE_URL'] = 'postgres://localhost/cataloguais_test'
  DataMapper::Logger.new($stdout, :error)
end

configure :development do
  ENV['ADMIN_PASSWORD'] = 'test'
  ENV['DATABASE_URL'] = 'postgres://localhost/cataloguais'
  DataMapper::Logger.new($stdout, :debug)
end

configure do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.auto_upgrade!
end

before do
  if ENV['ADMIN_PASSWORD'].nil?
    warn "!!! Admin password not set - editing will be enabled by default" unless ENV['RACK_ENV'] == 'test'
    session['editing_enabled'] = true
  end
end

before /(new|update|delete|import)/ do
  if !session['editing_enabled']
    data = { :status => 'error', :message => 'Hey, Mike! Editing must be enabled to do that!' }.to_json
    halt data
  end
end

# empty graph urls so they will be recreated the next time
# the graphs page is visited
after /(new|update|delete|import)/ do
  set :graph_urls, {}
end

get '/' do
  @sort = if params[:sort]
            [params[:sort]] + (settings.sort_order - [params[:sort]])
          else
            settings.sort_order
          end
  @direction = params[:direction] || :asc
  @direction = @direction.to_sym if @direction
  @items = Item.search_and_sort(@sort.dup, @direction, params[:search])
  haml :index
end

get '/export' do
  headers "Content-Disposition" => "attachment;filename=collection_#{Time.now.strftime("%y%m%d%H%M%S")}.csv", "Content-Type" => "application/octet-stream"
  CSV.generate do |file|
    file << Item.fields
    Item.all.each do |item|
      file << item.to_a
    end
  end
end

get '/random' do
  @items = [Item.get_random]
  @sort = settings.sort_order
  @direction = :asc
  haml :index
end

post '/new' do
  item = Item.create(params[:item])
  { :status => 'success', :message => 'Item successfully added.', :item_markup => item_table_row(item) }.to_json
end

post '/update/:id' do
  item = Item.first(:id => params[:id])
  item.attributes = params[:item]
  item.save!
  { :status => 'success', :message => 'Item successfully updated.', :item_markup => item_table_row(item) }.to_json
end

delete '/delete/:id' do
  Item.first(:id => params[:id]).destroy
  {:status => 'success', :message => 'Item successfully deleted.'}.to_json
end

post '/import' do
  redirect('/?message=You must upload a file') if !params[:file]

  # construct an array of hashes from the data
  # from http://snippets.dzone.com/posts/show/3899
  csv_data = CSV.read params[:file][:tempfile]
  headers = csv_data.shift.map {|i| i.to_s }
  string_data = csv_data.map {|row| row.map {|cell| cell.to_s.force_encoding('utf-8') } }
  array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

  Item.transaction do
    array_of_hashes.each { |attrs| Item.create(attrs) }
  end

  redirect "/?message=Imported #{array_of_hashes.count} items"
end

get '/stylesheet.css' do
  sass :stylesheet
end

get '/print.css' do
  sass :print
end

post '/login' do
  session['editing_enabled'] = true if ENV['ADMIN_PASSWORD'] && params[:password] == ENV['ADMIN_PASSWORD']
  redirect '/'
end

get '/logout' do
  session['editing_enabled'] = nil
  redirect '/'
end

get '/graphs' do
  set_graph_urls if settings.graph_urls.empty?
  haml :graphs
end

# catch trailing spaces from https://gist.github.com/867165
get %r{(.+)/$} do |r| redirect r; end;

# render the row of the table for a given partial
def item_table_row(item)
  @item = item
  haml :_item, :layout => false
end

def opposite_direction
  @direction == :asc ? :desc : :asc
end

# Get the occurrences of values for each field on Item
def get_occurrences
  occurrences = {}

  settings.fields.each do |field|
    occurrences[field] = {}

    # use SQL grouping for fast calculation
    items = DataMapper.repository.adapter.select("SELECT #{field.robotize} as \"col\", COUNT(*) as \"times\" FROM items GROUP BY #{field.robotize} ORDER BY \"times\" desc")

    # copy the items into the occurrences (since they are an array of structs after selection)
    items.each do |item|
      occurrences[field][item[:col]] = item[:times]
    end

    # group all the 1s together
    if (others = occurrences[field].select{|k,v| v==1}.size) > 1
      occurrences[field].delete_if{|k,v| v==1}
      occurrences[field]["Other"] = others
    end
  end

  occurrences
end

# calculate the occurrences and set the graph urls
def set_graph_urls
  get_occurrences.each do |label, data_set|
    # generate labels with the number of items
    labels = data_set.keys.each_with_index.collect { |key, i| "#{key} (#{data_set.values[i]})" }
    img_src = Gchart.pie(:labels => labels, :data => data_set.values, :size => '750x400', :bg => '2f2f2f', :bar_colors => '336688')

    # Request length must be less than 2048, otherwise it will fail
    if img_src.length < 2048
      settings.graph_urls[label] = img_src
    else
      warn "!!! Request length for '#{label}' graph is too long. Skipping."
    end
  end
end



