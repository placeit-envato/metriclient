# Path to the app
@dir = "/var/www/current"

worker_processes 8
working_directory @dir
preload_app true
timeout 60

# Unicorn socket to listen to
listen "/var/shared/tmp/sockets/unicorn.sock", :backlog => 64

# PID path
pid "/var/shared/tmp/pids/metriclient.pid"

# Set up the logger
logger Logger.new("/var/shared/log/unicorn.log")
stderr_path "/var/shared/log/unicorn.stderr.log"
stdout_path "/var/shared/log/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    Add a comment to this line
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(Metriclient::DatabaseManager) and Metriclient::DatabaseManager.instance
end
