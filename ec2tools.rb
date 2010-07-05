require 'rubygems'
require 'AWS'
require 'aws/s3'
require 'yaml'

class EC2 < AWS::EC2::Base
  ACCOUNT_YAML = '.account.yaml'
  SERVERS_YAML = '.servers.yaml'
  
  def initialize
    super(self.class.load_account)
    update_servers
  end
  
  def self.load_account
    return @config if @config
    file = '.account.yaml'
    if File.exists?(ACCOUNT_YAML)
      config = YAML.load_file(ACCOUNT_YAML)
    end
    raise if config.nil?
    @config = {
      :access_key_id => config["key"],
      :secret_access_key => config["secret"],
      :server => config["server"]
    }
  end
  
  def update_servers
    @servers = {}
    instances = describe_instances
    instances.reservationSet.item.each do |reservation|
      reservation.instancesSet.item.each do |instance|
        if instance.instanceState.name == "running"
          @servers[instance.keyName.to_sym] = [] if @servers[instance.keyName.to_sym].nil?
          @servers[instance.keyName.to_sym] << instance
        end
      end
    end
  end
  
  def servers(options = {})
    key = options[:key].to_sym
    if options[:num]
      num = options[:num].to_i
      [@servers[key][num]]
    else
      @servers[key]
    end
  end
  
  def server(options = {})
    servers(options).first
  end
  
  def self.s3
    config = load_account
    s3_config = {
      :access_key_id => config[:access_key_id],
      :secret_access_key => config[:secret_access_key]
    }
    AWS::S3::Base.establish_connection!(s3_config)
  end
end
