# include_recipe "encrypted_attributes::users_data_bag"

# self.class.send(:include, Chef::EncryptedAttributesHelpers)
self.class.send(:include, Opscode::OpenSSL::Password)

# mysql_root_password = encrypted_attribute_write(['snowglobe_mysql', 'root_password']) do
#   secure_password
# end

# mysql_debian_password = encrypted_attribute_write(['snowglobe_mysql', 'debian_password']) do
#   secure_password
# end

# mysql_repl_password = encrypted_attribute_write(['snowglobe_mysql', 'repl_password']) do
#   secure_password
# end

node.set_unless['mysql']['server_root_password'] = secure_password
node.set_unless['mysql']['server_debian_password'] = secure_password
node.set_unless['mysql']['server_repl_password'] = secure_password

include_recipe "mysql::server"

node.set_unless['pdns']['authoritative']['config']['gmysql_password'] = secure_password

pdns_config = node['pdns']['authoritative']['config']

connection = {
  :host => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password'],
}

mysql_database pdns_config['gmysql_dbname'] do
  connection connection
  action :create
  notifies :query, "mysql_database[create pdns tables]"
end

mysql_database_user pdns_config['gmysql_user'] do
  connection connection
  password pdns_config['gmysql_password']
  database_name pdns_config['gmysql_dbname']
  privileges [:all]
  action [:create, :grant]
end

schema_file = "/etc/powerdns_mysql_schema.sql"

cookbook_file schema_file do
  source "powerdns_schema.sql"
end

mysql_database "create pdns tables" do
  database_name pdns_config['gmysql_dbname']
  connection connection
  sql { ::File.open(schema_file).read }
  action :nothing
end


# o/ pdns cookbook

node.default['pdns']['authoritative']['config'].delete('pipe_command')
