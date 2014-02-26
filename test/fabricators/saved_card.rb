Fabricator(:saved_card) do
  first_name "George"
  last_name "Smith"
  card_number "4000100011112224"
  card_type "Visa"
  card_cvv "200"
  street1 "first street"
  zip "12345"
  expires_on Time.utc(2014, 9)
end
