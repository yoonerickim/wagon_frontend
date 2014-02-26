Factory.define :user do |u|
  u.first_name 'Fred'
  u.last_name 'Flintstone'
  u.sequence(:email) { |n| "fred#{n}@flintstones.com" }
  u.sequence(:phone) { |n| "123-123-#{n.to_s.rjust(4,'0')}" }
  u.password "password"
end

Factory.define :vendor do |v|
  v.name "Prehistoric Burgers"
end

Factory.define :tag do |t|
  t.sequence(:name) { |n| "Tag#{n}" }
end

Factory.define :location do |l|
  l.phone "123-123-1234"
  l.address_delivery true
end
