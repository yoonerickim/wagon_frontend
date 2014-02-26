
rails_env = ENV["RAILS_ENV"] || "development"
env = ENV["RAILS_ENV"] || "development"

worker_processes (env == 'production' ? 3 : 2) 
preload_app true
timeout 30
listen '/tmp/unicorn.hts.sock', :backlog => 2048


if env == "production" || env == "staging"
  working_directory "/home/ec2-user/apps/hts/current"
  user 'ec2-user'
  shared_path = '/home/ec2-user/apps/hts/shared'
  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  old_pid = "#{shared_path}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      #sig = (worker.nr + 1) >= server.worker_processes ? :INT : :TTOU
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end


after_fork do |server, worker|

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
   
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'ec2-user', 'ec2-user'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if RAILS_ENV == 'development'
      STDERR.puts "couldn't change user, oh well"
    else
      raise e
    end
  end
end


