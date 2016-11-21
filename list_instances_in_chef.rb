#!/usr/bin/env ruby

# list all instances in Chef server 

require "awesome_print"
require 'json'
require 'net/http'
require 'openssl'
require 'ridley'
require 'uri'

# add lib directory 
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# load config 
require "chef_compliance_config" 

# use ridley to access chef server 
Ridley::Logging.logger.level = Logger.const_get 'ERROR'
ridley = Ridley.new(
  server_url:   ChefConf.server_url,
  client_key:   ChefConf.client_key,
  client_name:  ChefConf.client_name
)

# get all nodes 
nodes = ridley.node.all

# get all nodes with all details   
#nodes = ridley.search(:node)  

# extract array of hashes
node_ids = []
name_hostnames = {}
name_fqdn = {}
name_ip = {}
name_env = {}

# examples of accessing details 
nodes.each do |n|
  nos = n.to_hash
  name = n["name"]
  env = n["chef_environment"]
  ipaddress = nos["automatic"]["ipaddress"]
  hostname = nos["automatic"]["hostname"]
  fqdn = nos["automatic"]["fqdn"]
  name_hostnames[name] = "#{hostname}"
  name_fqdn[name] = "#{fqdn}"
  name_ip[name] = "#{ipaddress}"
  name_env[name] = "#{env}"
  node_ids.push(name)
end

chef_nodes = node_ids.sort
ap chef_nodes
ap "Total: #{chef_nodes.length} instances in Chef"



