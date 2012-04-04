current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "djholt"
client_key               "#{current_dir}/djholt.pem"
validation_client_name   "djh-demo-validator"
validation_key           "#{current_dir}/djh-demo-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/djh-demo"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks", "#{current_dir}/../site-cookbooks"]

knife[:flavor] = "m1.small"
knife[:image] = "ami-349b495d" # Ubuntu 10.04.4 64-bit
knife[:aws_access_key_id] = ""
knife[:aws_secret_access_key] = ""
knife[:aws_ssh_key_id] = ""
