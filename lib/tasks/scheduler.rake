namespace :scheduler do
  namespace :orders do
    desc "Process fulfilled orders that have not been captured."
    task :process => :environment do
      puts "Processing #{Order.processable.count} orders."
      Order.process!
      puts "Completed processing orders."
    end

    desc "Send reminder notifications to location of submitted orders."
    task :remind => :environment do
      puts "Sending reminders for #{Order.remindable.count} orders."
      Order.remind!
      puts "Completed order reminders."
    end

    desc "Notify subscribing super users of non-confirmed orders."
    task :aging => :environment do
      puts "Notifying superusers of #{Order.aging.count} orders."
      Order.aging_alerts!
      puts "Completed notifying super users."
    end
  end # end orders ns
end
