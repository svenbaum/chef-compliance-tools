#!/usr/bin/env ruby

# Update compliance server by adding/removing nodes in sync with the Chef server 

require "awesome_print"
require 'colorize' 
require 'json'
require 'net/http'
require 'openssl'
require 'pp' 
require 'uri'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

#--------------------------------------
# Compliance nodes 

require "compliance_api"

# get environments
response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs")
envs = JSON.parse(response.body)

# array of nodes in compliance postgres database
allnodes = []

# iterate over all environments to get all nodes 
envs.each { |e|
  response = api_call('GET', "/owners/#{ComplianceConf.api_org}/envs/#{e['id']}/nodes")
  allnodes += JSON.parse(response.body)
} 

compliance_nodes = allnodes.compact
#ap compliance_nodes

compliance_ids = []
compliance_nodes.each { |i|
  i.each do |k,v|
    next unless (k =~ /id/)
    compliance_ids.push(v)
  end
} 
#ap compliance_ids


#--------------------------------------
# Chef nodes 

# load config
require "chef_compliance_config"
require "ridley" 

# use ridley to access chef server
Ridley::Logging.logger.level = Logger.const_get 'ERROR'
ridley = Ridley.new(
  server_url:   ChefConf.server_url,
  client_key:   ChefConf.client_key,
  client_name:  ChefConf.client_name
)

# large object nodes
chef_nodes = ridley.search(:node)
#ap nodes

# extract array of hashes
chef_ids = []
chef_nodes.each do |n|
  chef_ids.push(n["name"])
end
#ap chef_ids


#--------------------------------------
# Compare: Compliance <=> Chef 

# Nodes in Chef
puts "\nTotal: #{chef_ids.length} nodes in Chef".colorize(:light_blue)
#  ap chef_ids.sort

# Nodes in Compliance
puts "\nTotal: #{compliance_ids.length} nodes in Compliance".colorize(:light_blue)
#  ap compliance_ids.sort

#--------------------------------------
# REMOVE nodes from Compliance

# Nodes in Compliance that are not in Chef anymore => REMOVE
remove_ids = []
remove_ids = (compliance_ids - chef_ids)
remove_ids = remove_ids.sort
puts "\nRemove: #{remove_ids.length} nodes from Compliance".colorize(:light_blue)
if (remove_ids.length > 0)
  ap remove_ids
end

remove_ids.each do |i|
  # get details of nodes from Compliance
  compliance_nodes.each { |n|
    n.each do |k,v|
      next unless (k =~ /id/)
      next unless (v =~ /#{i}/)
      api_call('DELETE', "/owners/#{ComplianceConf.api_org}/envs/#{n["environment"]}/nodes/#{v}")
    end  
  }
end 

 
#--------------------------------------
# INSERT nodes into Compliance 

# Nodes in Chef that are not found in Compliance => INSERT
insert_ids = []
insert_ids = (chef_ids - compliance_ids)
insert_ids = insert_ids.sort 
puts "\nInsert: #{insert_ids.length} nodes into Compliance".colorize(:light_blue)
if (insert_ids.length > 0)
  ap insert_ids
  puts "\nDetails of inserted nodes:\n".colorize(:light_blue)
end


 
# INSERT nodes into compliance 
insert_ids.each do |i|
  
  # get nodes details from chef server 
  nodes_array = []
  chef_nodes.each do |n|
    next unless (n["name"] =~ /#{i}/) 
    nodes_array << { 
                     id: n["name"],
                     name: n["name"],
                     hostname: n["automatic"]["ipaddress"],
                     environment: n["chef_environment"],
                     loginUser: 'compliance',
                     loginMethod: 'ssh',
                     loginKey: 'compliance/compliance' }
    end  
    ap nodes_array 
     
    # Post the nodes to the Compliance Server
    response = api_call('POST', "/owners/#{ComplianceConf.api_org}/nodes", nodes_array.to_json)

    if response.code == '200'
      puts "Successfully imported node [#{i}] into Compliance\n".colorize(:light_blue)
    else
      puts "Failed to import, reason: #{response.body} code: #{response.code}\n".colorize(:light_red)
    end
end
 


