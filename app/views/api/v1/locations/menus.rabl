collection @menus => :menus

attributes :id, :name, :description, :start, :end

child :available_hours => :available_hours do
  attributes :closed
  node :open_at do |hour|
     if hour.open_at.present?
       hour.open_at.seconds_since_midnight
     else 
       nil
     end
   end
  node :close_at do |hour|
     if hour.close_at.present?
       hour.close_at.seconds_since_midnight
     else 
       nil
     end
   end
end

child :delivery_hours => :delivery_hours do
  attributes :closed
  node :open_at do |hour|
     if hour.open_at.present?
       hour.open_at.seconds_since_midnight
     else 
       nil
     end
   end
  node :close_at do |hour|
     if hour.close_at.present?
       hour.close_at.seconds_since_midnight
     else 
       nil
     end
   end
end


child :groups => :groups do
  attributes :id, :name, :description

  child :items => :items do
    attributes :id, :name, :description, :price

    node :image_url do |item|
      request.base_url + item.image.thumb('80x80#').url if item.image.present?
    end

    child :sizes => :sizes do
      attributes :id, :name, :description, :price
    end

    child :options => :options do
      attributes :id, :name, :information, :minimum, :maximum

      child :option_items => :items do
        attributes :id, :name, :additional_cost
      end
    end
  end

  child :options => :options do
    attributes :id, :name, :information, :minimum, :maximum

    child :option_items => :items do
      attributes :id, :name, :additional_cost
    end
  end
end
