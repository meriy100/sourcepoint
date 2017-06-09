# -*- coding: utf-8 -*-
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true # 更新時ダウンタイム無し

listen "#{ENV['RAILS_ROOT']}/tmp/unicorn.sock"
# listen 8080
pid "#{ENV['RAILS_ROOT']}/tmp/unicorn.pid"

before_fork do |_server, _worker|
  Signal.trap "TERM" do
    logger.fatal "Unicorn master intercepting TERM and sending myself QUIT instead"
    Process.kill "QUIT", Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  Signal.trap "TERM" do
    logger.fatal "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT"
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end

# ログの出力
stderr_path File.expand_path("log/unicorn.log", ENV["RAILS_ROOT"])
stdout_path File.expand_path("log/unicorn.log", ENV["RAILS_ROOT"])

