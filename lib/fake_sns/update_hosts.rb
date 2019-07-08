Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'socket'
require 'hosts'
require 'sudo'

def update_hosts
  Sudo::Wrapper.run do |sudo|
    ip = IPSocket.getaddress(Socket.gethostname)
    hosts = Hosts::File.read('/etc/hosts')

    if_none = lambda do
      entry = Hosts::Entry.new(ip, 'fakesns',
                               :aliases => ['sns.aws.local'],
                               :comment => 'Fake SNS local')
      hosts.elements << entry
      entry
    end

    element = hosts.elements.find(if_none) do |element|
      next unless element.respond_to?(:name)
      element.name == "fakesns"
    end

    element.address = ip

    sudo[hosts].write
  end
end
