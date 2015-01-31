include_recipe "encrypted_attributes::users_data_bag"


self.class.send(:include, Chef::EncryptedAttributesHelpers)
self.class.send(:include, Opscode::OpenSSL::Password)

mysql_root_password = encrypted_attribute_write(['snowglobe_mysql', 'root_password']) do
  secure_password
end

mysql_debian_password = encrypted_attribute_write(['snowglobe_mysql', 'debian_password']) do
  secure_password
end

mysql_repl_password = encrypted_attribute_write(['snowglobe_mysql', 'repl_password']) do
  secure_password
end

mysql_host = '127.0.0.1'
mysql_port = '3306'

mysql_service node['mysql']['service_name'] do
  version node['mysql']['version']
  port mysql_port
  data_dir node['mysql']['data_dir']
  server_root_password mysql_root_password
  server_debian_password mysql_debian_password
  server_repl_password mysql_repl_password
  allow_remote_root node['mysql']['allow_remote_root']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_network_acl node['mysql']['root_network_acl']
  package_version node['mysql']['server_package_version']
  package_action node['mysql']['server_package_action']
  enable_utf8 node['mysql']['enable_utf8']
  action :create
end

conn = {
  :host => mysql_host,
  :port => mysql_port,
  :password => mysql_root_password,
  :username => 'root',
}

mysql_wordpress_password = encrypted_attribute_write(['snowglobe_mysql', 'wordpress_password']) do
  secure_password
end

db = node['wordpress']['db']

mysql_database db['name'] do
  connection conn
  action :create
end

mysql_database_user db['user'] do
  connection conn
  password mysql_wordpress_password
  database_name db['name']
  privileges [:all]
  action [:create, :grant]
end
