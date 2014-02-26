require 'test_helper'

class Api::V1::OrdersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  #
  def setup
    @user = Fabricate(:user)
    assert @user.set_mobile_token(device_uid: 'dev123', version_uid: 'ios/DEVELOPMENT')
    @user.save!
  end

  def test_can_update_order
      @order = Fabricate.build(:order)
      @order.user = @user
      @order.save!
      @order.saved_card = Fabricate.build(:saved_card)
      @order.saved_card.user = @user
      @order.submit!
      params = {
        id: @order.id,
        token: @user.mobile_token.token,
        order: {
          terms: 1,
          saved_card_id: @order.saved_card_id,
          delivery_spot_attributes: {
          }
        }
      }
      post :update, params
      assert_response 200
  end


  def test_cannot_update_confirmed_order
      @order = Fabricate.build(:order)
      @order.user = @user
      @order.save!
      @order.saved_card = Fabricate.build(:saved_card)
      @order.saved_card.user = @user
      @order.submit!
      @order.confirm!
      params = {
        id: @order.id,
        token: @user.mobile_token.token,
        order: {
          terms: 1,
          saved_card_id: @order.saved_card_id,
          delivery_spot_attributes: {
          }
        }
      }
      post :update, params

      assert_response 400
  end

end
