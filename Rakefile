require "json"
require "socket"

namespace :fluent do
  desc "Start fluentd"
  task :start do
    logfile = "log/fluentd.log"
    print "==> start fluentd..."
    `fluentd -d fluentd.pid -c conf/fluent.conf -o #{logfile}`
    if $?.exitstatus == 0
      puts "success"
      puts "pid: #{$?.pid}"
    else
      puts "failed"
    end
    puts "see #{logfile}"
  end

  desc "Emit logs to the hadoop cluster"
  task :cat do
    ip = IPSocket.getaddress('localhost')
    10.times do |i|
      access_log = sprintf('%s - - [%s] "GET / HTTP/1.1" 200 44723 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.5.3 (KHTML, like Gecko) Version/8.0.5 Safari/600.5.3"', ip, Time.now.strftime('%d/%b/%Y:%H:%M:%S %z'))
      data = {"message" =>  access_log}.to_json
      `echo '#{data}' | fluent-cat access.log`
    end
  end
end
