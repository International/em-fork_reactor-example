elements   = (1..2).to_a
processes  = 2

proc_queue = []
pids       = {}

elements.each do |elem|
  puts "Using element #{elem}"
  rd, wr = IO.pipe
  if pid = fork
    wr.close
    pids[pid] = rd
  else
    # child
    sleeping_for = (Random.rand * 100 % 20).to_i
    puts "Sleeping for #{sleeping_for}"

    rd.close
    sleep sleeping_for
    wr.write elem*2
    exit
  end
end

puts "Parent process."
Process.waitall
puts "Trying to read"
pids.each do |pid, rpipe|
  puts "#{rpipe.read}"
end