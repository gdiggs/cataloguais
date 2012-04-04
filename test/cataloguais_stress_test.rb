require_relative './test_helper'
require 'securerandom'

class CataloguaisTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  # create a specific number of items (default to 500)
  def reset_db(num_items = 500)
    DataMapper.repository.adapter.execute("DELETE FROM items")
    time = Benchmark.measure do
      Item.transaction do
        # create a bunch of items
        num_items.times do
          item = Item.new
          settings.fields.each do |field|
            item.send("#{field.robotize}=", SecureRandom.base64(42))
          end
          item.save
        end
      end
    end
    puts "Created #{num_items} items in #{time.real} seconds"
  end

  10.times do |i|
    context "with #{1000*(i+1)} items" do
      setup do
        @num_items = 1000 * (i+1)
        reset_db(@num_items) unless @num_items == Item.count
      end

      should "not take too long to do GET /" do
        time = Benchmark.measure { get '/' }
        puts "GET / took #{time.real} seconds with #{@num_items} items"
      end

      should "not take too long to do GET /export" do
        time = Benchmark.measure { get '/export' }
        puts "GET /export took #{time.real} seconds with #{@num_items} items"
      end

      should "not take too long to do GET /graphs" do
        settings.graph_urls = {}
        assert settings.graph_urls.empty?
        time = Benchmark.measure { get '/graphs' }
        puts "GET /graphs (with occurrence calculation) took #{time.real} seconds with #{@num_items} items"
      end
    end
  end

end
