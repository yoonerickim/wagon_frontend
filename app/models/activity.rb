class Activity < ActiveRecord::Base
  belongs_to :user
  
  #activitiy types 
  NO_COVERAGE = '1'
  
end
