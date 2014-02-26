require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase

  def setup
    @user_params = {
      format: :json,
      device_uid: 123,
      version_uid: "ios/DEVELOPMENT",
      user: {
        first_name: "First", 
        last_name: "Last", 
        email: "first@first.com", 
        password: "password", 
        password_confirmation: "password"
      }
    }
    @user = Fabricate(:user)
    @auth_params = {
      username: @user.email, 
      password: "password", 
      device_uid: "1234abcd", 
      version_uid: "ios/DEVELOPMENT"
    }
  end

  def test_create_a_user
    post :create, @user_params
    assert_response 201
  end

  def test_create_fails_when_missing_required_param
    @user_params.delete(:device_uid)
    post :create, @user_params
    assert_response 400
    assert @response.body.blank?
  end

  def test_create_returns_error_when_invalid_data
    @user_params[:user][:password_confirmation] = 'nomatch'
    post :create, @user_params
    assert_response 400
    assert_equal ["Password doesn't match confirmation"], json['errors']
  end

  def test_authenticate_user
    post :authenticate, @auth_params
    assert_response 200
    assert json['user']['token'].has_key? 'token'
    assert json['user']['token'].has_key? 'expires_at'
    assert json['user'].has_key? 'can_deliver'
    assert_equal false, json['user']['can_deliver']
  end

  def test_authenticate_user
    @auth_params[:username] = @auth_params[:username].capitalize
    post :authenticate, @auth_params
    assert_response 200
    assert json['user']['token'].has_key? 'token'
    assert json['user']['token'].has_key? 'expires_at'
    assert json['user'].has_key? 'can_deliver'
    assert_equal false, json['user']['can_deliver']
  end

  def test_auth_fails_with_incorrect_password
    @auth_params[:password] = 'wrong'
    post :authenticate, @auth_params
    assert_response 401
    assert @response.body.blank?
  end

  def test_auth_fails_with_incorrect_version
    @auth_params[:version_uid] = 'too_old'
    post :authenticate, @auth_params
    assert_response 400
    assert_equal ["Version too old. Please update."], json['errors']
  end

  def test_auth_fails_without_device_uid
    @auth_params[:device_uid] = ''
    post :authenticate, @auth_params
    assert_response 400
    assert_equal ["Device uid can't be blank"], json['errors']
  end

  def test_refresh
    Timecop.freeze(Time.now) do
      assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
      @refresh_params = {
        token: @user.mobile_token.token
      }

      Timecop.freeze(Time.now + 10.minutes) do
        post :refresh, @refresh_params
        assert_response 200
        assert_equal @refresh_params[:token], json['token']['token']
      end
    end
  end

  def test_refresh_expired
    Timecop.freeze(Time.now) do
      assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
      @refresh_params = {
        token: @user.mobile_token.token
      }

      Timecop.freeze(Time.now + MobileToken::EXPIRATION) do
        post :refresh, @refresh_params
        assert_response 403
      end
    end
  end

  def test_can_load_saved_cards
    card = Fabricate.build(:saved_card)
    card.user = @user
    card.save

    assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')

    get :saved_cards, {:token => @user.mobile_token.token}

    assert_response 200
    assert_equal 1, json['saved_cards'].length
    assert_equal 'first street', json['saved_cards'][0]['street1']
  end


  def test_loading_cards_without_token_fails
    card = Fabricate.build(:saved_card)
    card.user = @user
    card.save

    get :saved_cards

    assert_response 401
  end

  def test_can_load_spots
    spot = Fabricate.build(:spot)
    spot.addressable = @user
    spot.save

    assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')

    get :spots, {:token => @user.mobile_token.token}

    assert_response 200
    assert_equal 1, json['spots'].length
    assert_equal 'My Hangout', json['spots'][0]['nickname']
  end


  def test_loading_spot_without_token_fails
    spot = Fabricate.build(:spot)
    spot.addressable = @user
    spot.save

    get :spots

    assert_response 401
  end

end
