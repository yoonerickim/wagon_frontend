uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Resque.redis = REDIS

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == 'preview' && password == 'goharnu'
end
