Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'socket'
require 'hosts'


def update_hosts
    ip = IPSocket.getaddress(Socket.gethostname)

    hosts = Hosts::File.read('/etc/hosts')

    if hosts.elements[-1].name == "sns.aws.local"
        hosts.elements[-1].address = ip
    else
        Hosts::Entry.new(ip, 'sns',
                         :aliases => ['sns.aws.local'],
                         :comment => 'Fake SNS local')
    end

    hosts.write
end
