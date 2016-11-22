# chef-compliance-toolsCollection of ruby scripts that interact with the Chef Compliance server by making REST-based API calls. The motivation is to provide a collection of command line utilities that list, delete or update the nodes in the Compliance server and to keep it in sync with the nodes registered with Chef. List all nodes in Chef ```Shellruby list_nodes_in_chef.rb```List all nodes in Compliance  ```Shellruby list_nodes_in_compliance.rb```Delete all nodes in Compliance  ```Shellruby delete_all_nodes_in_compliance.rb```Update Compliance server by adding/removing nodes depending on if they are in Chef  ```Shellruby update_compliance_server.rb```