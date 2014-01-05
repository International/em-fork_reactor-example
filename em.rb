require "rubygems"
require "bundler"

Bundler.require(:default)

children = []
 
Signal.trap('SIGINT') do
  EventMachine.next_tick { EventMachine.stop_event_loop }
end
 
Signal.trap('EXIT') do
  puts "Killing #{children.size} children ..."
 
  children.each do |pid|
    Process.kill('SIGUSR1', pid) rescue Exception
  end
end

EM.synchrony do
  channel = EM::Channel.new

  channel.subscribe do |msg|
    puts "received #{msg}"
  end

  pid = EM.fork_reactor do 
    EM.add_periodic_timer(1) do
      channel.push "hello from child reactor"
    end
  end

  EM.add_periodic_timer(5) do
    puts "father reactor"
  end

  Process.detach(pid)
end