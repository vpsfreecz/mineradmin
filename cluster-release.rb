#!/usr/bin/env ruby
#
# Read cluster layout from cluster.json or the first argument
# and build release for every cluster node.
# Example `cluster.json` file:
#
#   {
#     "all": [
#       "node1@192.168.122.1"
#     ],
#     "worker": [
#       "node2@192.168.122.2",
#       "node2@192.168.122.3",
#       "node2@192.168.122.4"
#     ]
#   }
#
# Object keys are release types (see `core/rel/config.exs`), values are
# arrays of node names. Built releases can be found at `releases/<env>/`.
#
# TODO: remote the need for sudo make clean (docker writes to the mounted
#       volume as root, so only root can delete it)

require 'json'
require 'optparse'

def cmd(s)
  pid = spawn(s)
  _, status = Process.wait2(pid)

  if status.exitstatus != 0
    warn "Command '#{s}' exited with #{status.exitstatus}"
    exit(false)
  end
end

def run
  options = {
    env: 'prod',
  }

  OptionParser.new do |opts|
    opts.on('-e', '--env ENV', 'Build environment') do |v|
      options[:env] = v
    end
  end.parse!

  cluster = JSON.parse(File.read(ARGV[0] || 'cluster.json'))

  cluster.each do |role, nodes|
    puts "Building core role #{role}"
    cmd("sudo make clean")
    cmd("make ENV=#{options[:env]} build_core")

    nodes.each do |node|
      puts "Building node #{node} (#{role})"
      cmd("make ENV=#{options[:env]} COOKIE=#{ENV['COOKIE']} NODE=#{node} TYPE=#{role} release_core")
    end
  end

  puts "Building gems"
  cmd("make ENV=#{options[:env]} mineradmin-client minerd minerdctl")
end

run
