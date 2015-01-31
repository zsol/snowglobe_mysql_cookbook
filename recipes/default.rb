include_recipe "encrypted_attributes::users_data_bag"


self.class.send(:include, Chef::EncryptedAttributesHelpers)

mysql_root_password = encrypted_attribute_write(['snowglobe_mysql', 'root_password']) do
  self.class.send(:include, Opscode::OpenSSL::Password)
  secure_password
end


mysql_service 'snowglobe' do
  version '5.6'
  bind_address '127.0.0.1'
  port '3306'
  initial_root_password mysql_root_password
  action [:create, :start]
  provider Chef::Provider::MysqlService::Upstart
end

mysql_client 'snowglobe'
