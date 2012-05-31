#!/usr/bin/ruby
#
# Simple client to send the current IP of the running machine to one or more
# bobd servers.
#

require 'socket'

def usage
  puts "edd <nic> <server-list>"
  puts ""
  puts "  The server-list is a space separated list of active bobd servers,"
  puts "  with the following format hostname:port"
  puts ""
end

def get_mac(nic)
  sock = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM,0)
  buf = [nic,""].pack('a16h16')
  sock.ioctl(0x8927, buf);
  sock.close
  puts buf
  return buf[18..24].to_etheraddr
end

def get_ip(nic)
  sock = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM,0)
  buf = [nic,""].pack('a16h16')
  sock.ioctl(0x8915, buf);
  sock.close
  puts bufs
  return buf[20..24].to_ipaddr4
end

# Make sure that bobd got at least one arguments
if ARGV.length < 2 then
  usage
  exit 1
end

# Handle standard user comfort :)
if "--help" == ARGV[0] or "-h" == ARGV[0] then
  usage
  exit 0
end

ethernet_card = ARGV[0]
servers = ARGV[1..-1]

quit = false

mac = get_mac ethernet_card

# Run forever
while (not quit)

  # If this client has goten a new IP, lets inform the servers.
  if ip == get_ip(ethernet_card)
    sleep 1
    next
  end

  ip = get_ip(ethernet_card)

  puts ip

  # Connect to a server in the list of servers in sequence, stop on first
  # successful update and let the servers do their job in synchronizing.
  servers.each do | s |
    reply = nil

    host = s.split(":")[0]
    port = s.split(":")[1]

    begin
      c = TCPSocket.new(host, port)

      puts "#{ip}"

      # Send magic string.
      c.puts "BOB!?\n"
      c.puts "#{mac}\n"
      c.puts "#{ip}\n"

      # Get magic string in reply.
      reply = c.gets
    rescue Exception => e
      puts e
      next
    end

    # Close the connection to the server.
    c.close

    # Evaluate the respons and bail out if the expected response "Okidoki" was
    # received.
    break if "ED!\n" == reply

  end

  sleep 1
end

exit 0
