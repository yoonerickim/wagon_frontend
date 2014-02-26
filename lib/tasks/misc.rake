namespace :gvendors do
  namespace :import do
    desc "back-fill order reimbursements and delivery fees."
    task :initial_set => :environment do
      require 'csv'
      lines = CSV.read("menu_data.csv")
      lines.shift
      for line in lines
        if line[0].present? and line[1].present? 
          gvendor = Gvendor.new
          gvendor.gid = line[0]
          gvendor.name = line[1]
          gvendor.menu_url = line[2] if line[2].present?
          gvendor.address1 = line[3] if line[3].present?
          gvendor.address2 = line[4] if line[4].present?
          gvendor.city = line[5] if line[5].present?
          gvendor.state = line[6] if line[6].present?
          gvendor.zip = line[7] if line[7].present?
          gvendor.phone = line[8].gsub(/\D/,'') if line[8].present?
          gvendor.lat = line[9] if line[9].present?
          gvendor.lng = line[10] if line[10].present?
          gvendor.save          
        end
      end
    end
  end
end