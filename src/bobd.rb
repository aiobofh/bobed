#!/usr/bin/ruby
#
# Simple server to get the IP of an ed-script call.
#

require 'socket'

def usage
  puts "bobd <clients-ip-file-path> <listen-port>"
  puts ""
  puts "  The clients-ip-file-path is where bobd will store its clients IP"
  puts "  addresses."
  puts ""
end

# Make sure that bobd got at least two arguments
if ARGV.length < 2
  usage
  exit 1
end

# Handle standard user comfort :)
if "--help" == ARGV[0] or "-h" == ARGV[0] then
  usage
  exit 0
end

path=ARGV[0]
port=ARGV[1]

# Start the server.
begin
  server = TCPServer.new(port)
rescue Exception => e
  puts e
  exit 1
end

quit = false

# Accept connections from clients
while ((s = server.accept) && (not quit))

  # Only accept magic string.
  if not "BOB!?\n" == s.gets
    s.close
    next
  end

  # Get MAC address of the client
  mac = s.gets

  # Make sure that the MAC address is a valid one (no destructive characters).

  # Write the IP of the sender to a file
  begin
    File.open("#{path}/#{mac}", 'w') do | f |
      f.puts "#{s.peeraddr[3]}"
    end
  rescue Exception => e
    puts e
    exit 2
  end

  # Send reply to client
  s.puts "ED!\n"

  s.close
end

exit 0
