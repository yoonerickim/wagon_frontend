class Api::V1::SavedCardsController < Api::V1::ApiController

  # Public: Create a card.
  #
  # params:
  # saved_card[card_number]
  # saved_card[card_cvv]
  # saved_card[card_type]: 'visa', 'american_express', 'master', 'discover'
  # saved_card[expires_on]: 'YYYY/MM/DD'
  # saved_card[first_name]
  # saved_card[last_name]
  # saved_card[street1]
  # saved_card[street2] -- optional
  # saved_card[city]
  # saved_card[state]
  # saved_card[zip]
  # 
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"token":"NEXLkolbf-ri8IRJAUnOA_ipafMMsKI6aYbjXukMixlSIq0AxB9WevHgEyPGrTTRHXx-dZIjcQ7Jf8RVxFkaaA", "saved_card":{"card_number":"4000100011112224", "card_cvv":"123", "card_type":"visa", "expires_on":"2012/12/01", "first_name":"Joe", "last_name":"Blow", "street1":"123 Main Street", "city":"Seattle", "state":"WA", "zip":"98102"}} http://localhost:8080/api/v1/saved_cards
  #
  # Returns created card or errors.
  def create
    requires! params, :token, :saved_card
    requires! params[:saved_card], :card_number, :card_cvv, :card_type, :expires_on
    requires! params[:saved_card], :first_name, :last_name
    requires! params[:saved_card], :street1, :zip

    @saved_card = @token.user.saved_cards.create(params[:saved_card])
    json_response
  end

  # Public: Update a card.
  #
  # params - same as create
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X PUT \
  #   -d '{"token":"PjMO-RCIXNxcOdDjEVS7kbn1N_T3SbxnssCdejybfyEQLMn7mOElZvNnnjrWE6wlsAc5hjjpA5jJSAQmicl_lg", \
  #   "saved_card":{"card_number":"4000100011112224", "card_cvv":"123", "card_type":"visa", \
  #   "expires_on":"2012/12/01", "first_name":"Joe", "last_name":"Blow", "street1":"123 Main Street", \
  #   "city":"Seattle", "state":"WA", "zip":"98102"}}' \
  #   http://localhost:8080/api/v1/saved_cards/2
  #
  # Returns the updated card.
  def update
    requires! params, :token, :id, :saved_card
    requires! params[:saved_card], :card_number, :card_cvv, :card_type, :expires_on
    requires! params[:saved_card], :first_name, :last_name
    requires! params[:saved_card], :street1, :zip

    @saved_card = @token.user.saved_cards.find(params[:id])
    @saved_card.update_attributes(params[:saved_card])
    json_response
  end

  # Public: Destroy a card.
  #
  # Examples:
  #
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X DELETE \
  #   -d '{"token":"4AURQw2KmLlUepf35BUZXdpnQGGW0xDyAMpmF8Nlh3RY1xXBN2Bxqo_BZWVGNhaA3MX0RTHAww_ac-RbTpIo4A"}' \
  #   http://localhost:8080/api/v1/saved_cards/1
  # 
  # Returns the card deleted.
  def destroy
    requires! params, :token, :id

    @saved_card = @token.user.saved_cards.find(params[:id])
    @saved_card.delete if @saved_card.present?
    json_response
  end

  private

  # Private: Render appropriate json.
  #
  def json_response
    if @saved_card.errors.empty?
      render 'show'
    else
      json_errors(@saved_card.errors.full_messages)
    end
  end

end
