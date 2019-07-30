# Environment:
#   CHEF_USER               - override USER
#   USER                    - login user
#   ORGNAME                 - override default name of 'hms' for organization
#   ORG_PREFERRED_DIR   - Override of HOME/.chef directory whenever possible
#   CHEF_FQDN               - Chef Server FQDN
#

# CWD
current_dir = File.dirname(__FILE__)
preferred_dir = ENV['ORG_PREFERRED_DIR'] || "#{ENV['HOME']}/.chef"

ssl_verify_mode :verify_none

# Logging
log_level                :info
log_location             STDOUT

# Org
ENV['ORGNAME'] = orgname = ENV['ORGNAME'] || 'hms'

# Server
chef_server_fqdn = ENV['CHEF_FQDN'] || 'default-chef-server.example.com'

# User
user = ENV['CHEF_USER'] || 'ttrimmer'

# Server Connect
node_name                user
client_key               "#{preferred_dir}/#{user}.pem"
chef_server_url          "https://#{chef_server_fqdn}/organizations/#{orgname}"

# Cache
cache_type               'BasicFile'
cache_options( :path => "#{preferred_dir}/checksums" )

# Cookbook
cookbook_path            ["#{current_dir}/../cookbooks"]
cookbook_copyright       'Example, Inc.'
cookbook_license         'reserved'
cookbook_email           'chefs@example.com'
