class ActionController::Base
  include LogAndNotify
end

class ActiveRecord::Base
  include LogAndNotify
end
