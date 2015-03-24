require 'genconfig/util'
require 'genconfig/data'

require 'yaml'

module GenConfig
  class Generator
    include GenConfig::Data
    include GenConfig::Utils

    def self.create( hypervisor_type )

      hclass = case hypervisor_type
      when /vmpooler/
        GenConfig::Vmpooler
      when /vagrant/
        GenConfig::Vagrant
      else
        raise "Invalid hypervisor #{type}"
      end

      hclass.new
    end

    def generate( tokens )
      nodeid = 1
      ostype = nil

      tokens.each do |toke|
        node_info = NODE_REGEX.match(toke)
        if node_info
          raise "Can't create a node without an OS" unless ostype

          node_info = {
            'bits' => node_info['bits'],
            'roles' => node_info['roles'],
            'ostype' => ostype,
            'nodeid' => nodeid,
          }

          host_name, host_config = generate_node node_info

          if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
            host_config['install_32'] = true
          end

          @config['HOSTS'][host_name] = host_config
          nodeid += 1
        else
          ostype = toke
        end
      end

      return @config.to_yaml
    end

    def generate_node
      raise "Method 'generate_node' not implemented!"
    end

  end
end

require 'genconfig/generator/vmpooler'
