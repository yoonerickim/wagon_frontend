Fabricator(:user) do
  first_name 'Fred'
  last_name 'Flintstone'
  email { sequence(:email) { |i| "fred#{i}@flintstones.com" } }
  password "password"
end
