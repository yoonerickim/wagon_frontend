require 'test_helper'

class Api::V1::SavedCardsControllerTest < ActionController::TestCase
  def setup
    @user = Fabricate(:user);
    assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
    @card_params = {
      token: @user.mobile_token.token,
      saved_card: {
        card_number: "4000100011112224",
        card_cvv: "200",
        card_type: "visa",
        street1: "first street",
        zip: "12345",
        expires_on: "2014/09/01",
        first_name: "george",
        last_name: "smith"
      }
    }
  end

  def test_create_card
    post :create, @card_params
    assert_response 200
    assert json.has_key? 'saved_card'

    saved_card = SavedCard.find(json['saved_card']['id'])
    assert_equal @card_params["card_number"], saved_card.card_number
  end

  def test_create_card_without_number
    @card_params[:saved_card][:card_number] = nil
    post :create, @card_params
    assert_response 400
    assert json.has_key? 'errors'
  end

  def test_update_card
    card = Fabricate.build(:saved_card)
    card.user = @user
    card.save

    @card_params[:id] = card.id
    @card_params[:saved_card][:first_name] = "Fatso"
    post :update, @card_params
    assert_response 200
    assert json.has_key? 'saved_card'

    card.reload
    assert_equal "Fatso", card.first_name
  end

  def test_delete_a_card
    card = Fabricate.build(:saved_card)
    card.user = @user
    card.save

    post :destroy, {id: card.id, token: @user.mobile_token.token}

    assert_response 200
    assert json.has_key? 'saved_card'

    assert_raises ActiveRecord::RecordNotFound do
      SavedCard.find(card.id)
    end
  end

  def test_delete_a_card_that_isnt_there
    card = Fabricate.build(:saved_card)
    card.user = @user
    card.save
    card.delete

    post :destroy, {id: card.id, token: @user.mobile_token.token}

    assert_response 404
  end
end
