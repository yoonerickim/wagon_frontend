require 'test_helper'

class Api::V1::SpotsControllerTest < ActionController::TestCase
  def setup
    @user = Fabricate(:user)
    assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
    @spot = Fabricate.build(:spot)
    @spot.addressable = @user
    @spot.save

    @spot_params = {
      token: @user.mobile_token.token,
      id: @spot.id,
      spot: {
        nickname: 'My House',
        lat: 4.0,
        lng: 5.0
      }
    }
  end

  def test_create_spot
    post :create, @spot_params
    assert_response 200
    assert_equal 'My House', json['spot']['nickname']
    key = json['spot']['id']
    Spot.find(key)
  end

  def test_create_spot_without_token_fails
    @spot_params.delete(:token)
    post :create, @spot_params
    assert_response 401
    assert @response.body.blank?
  end

  def test_update_spot
    post :update, @spot_params
    assert_response 200
    assert_equal 'My House', json['spot']['nickname']
    @spot.reload
    assert_equal 'My House', @spot.nickname
  end

  def test_delete_spot
    post :destroy, @spot_params
    assert_response 200
    assert_equal 'My Hangout', json['spot']['nickname']
    assert_raises ActiveRecord::RecordNotFound do
      Spot.find(@spot.id)
    end
  end
end
