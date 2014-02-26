require 'test_helper'

class Api::V1::LocationsControllerTest < ActionController::TestCase
  def setup
    @location = Fabricate(:location)
    @location.address = Fabricate(:address)
    @location.vendor = Fabricate(:vendor)
    @location.save

    @menu = Fabricate(:menu)
    @menu.location = @location
    @menu.save
  end

  def test_complains_with_zero_parameters
    get :fetch
    assert_response 400
    assert @response.body.blank?
  end

  def test_fetch_the_record
    get :fetch, {:lat => @location.address.lat, :lng => @location.address.lng, :t => Order::DINE_IN}
    assert_response 200
    assert json['locations'].kind_of? Array
  end

  def test_fetch_incorrect_order_type
    get :fetch, {:lat => @location.address.lat, :lng => @location.address.lng, :t => Order::SPOT_DELIVERY}
    assert_response 200
    assert_equal 0, json['locations'].length
  end

  def test_fetch_the_record_with_query_text
    # Pizza should match the name of the vendor
    get :fetch, {:lat => @location.address.lat, :lng => @location.address.lng, 
      :t => Order::DINE_IN, :q => "Pizza"}
    assert_response 200
    assert_equal 1, json['locations'].length
    assert_equal "Dave's Pizza", json['locations'][0]['vendor']['name']
  end

  def test_fetch_the_record_with_incorrect_query_text
    get :fetch, {:lat => @location.address.lat, :lng => @location.address.lng, 
      :t => Order::DINE_IN, :q => "Burger"}
    assert_response 200
    assert_equal 0, json['locations'].length
  end

  def test_fetch_menu
    get :menus, {:id => @location.id}
    assert_response 200
    assert_equal 1, json['menus'].length
    assert_equal "Dinner", json['menus'][0]['name']
  end
end
