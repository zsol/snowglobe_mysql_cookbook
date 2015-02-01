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
