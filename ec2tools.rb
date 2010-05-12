require 'rubygems'
require 'AWS'
require 'yaml'

class EC2 < AWS::EC2::Base
  ACCOUNT_YAML = '.account.yaml'
  SERVERS_YAML = '.servers.yaml'
  
  def initialize
    super(load_account)
    update_servers
  end
  
  def load_account
    file = '.account.yaml'
    if File.exists?(ACCOUNT_YAML)
      config = YAML.load_file(ACCOUNT_YAML)
    end
    raise if config.nil?
    {:access_key_id => config["key"], :secret_access_key => config["secret"], :server => config["server"]}
  end
  
  def update_servers
    @servers = {}
    instances = describe_instances
    instances.reservationSet.item.each do |reservation|
      reservation.instancesSet.item.each do |instance|
        @servers[instance.keyName.to_sym] = [] if @servers[instance.keyName].nil?
        @servers[instance.keyName.to_sym] << instance
      end
    end
  end
  
  def server(options = {})
    key = options[:key].to_sym
    num = options[:num].to_i
    @servers[key][num]
  end
end
