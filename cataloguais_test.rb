require './cataloguais'
require 'shoulda-context'
require 'test/unit'
require 'rack/test'

set :environment, :test

class CataloguaisTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # set up the test db
  MongoMapper.database = "cataloguais_test"
  Item.all.each { |item| item.destroy }

  context "settings" do
    should "have the right number of fields" do
      assert_equal settings.field_count, settings.fields.count
    end

    should "have item width" do
      assert_not_nil settings.item_width
    end
  end

  context "HTTP Methods" do
    context "GET /" do
      setup do
        get '/'
      end

      should "have good response" do
        assert last_response.ok?
      end
    end

    context "POST /new/" do
      setup do
        post '/new/', {:item => { :title => "My favorite album" }}
        @response = JSON.parse(last_response.body)
      end

      should "have good response" do
        assert last_response.ok?
      end

      should "return new item" do
        assert_not_nil @response["item_markup"]
      end

      should "return correct message" do
        assert @response["message"] =~ /added/
      end
    end

    context "POST /update/:id" do
      setup do
        @item = Item.create
        post "/update/#{@item.id}", { :item => { :title => "My favorite album" }}
        @item = @item.reload
        @response = JSON.parse(last_response.body)
      end

      should "have good response" do
        assert last_response.ok?
      end

      should "have updated field" do
        assert_equal "My favorite album", @item.title
      end

      should "have correct message" do
        assert @response["message"] =~ /updated/
      end
    end

    context "DELETE /delete/:id" do
      setup do
        @item = Item.create
        @item_id = @item.id
        delete "/delete/#{@item_id}"
        @response = JSON.parse(last_response.body)
      end

      should "have good response" do
        assert last_response.ok?
      end
      
      should "have correct message" do
        assert @response["message"] =~ /deleted/
      end

      should "remove item" do
        assert_nil Item.find_by_id(@item_id)
      end
    end
  end

  context "Item" do
    setup do
      @item = Item.new()
    end

    should "have the right number of fields and methods" do
      settings.fields.each_with_index do |field, i|
        assert @item.respond_to?(field.robotize), "Item didn't respond to #{field.robotize}"
        assert @item.respond_to?("field#{i}"), "Item didn't respond to field#{i}"
      end
    end

    context ".fields" do
      should "return the correct fields" do
        assert_equal settings.fields.collect{ |field| field.robotize }, Item.fields
      end
    end
  end

end
