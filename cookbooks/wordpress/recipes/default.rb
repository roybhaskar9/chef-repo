# This is a Chef recipe file. It can be used to specify resources which will
# apply configuration to a server.

log "Welcome to Chef, #{node["starter_name"]}!" do
  level :info
end

execute 'apt_update'  do
  command 'apt update'
end

#packages = ['apache2', 'mysql-server', 'mysql-client', 'php', 'libapache2-mod-php', 'php-mcrypt', 'php-mysql']
packages = node["package"]
packages.each do |package|
 apt_package package do
   action :install
 end
end

execute "setrootpassword" do
  command "mysqladmin -uroot password rootpassword && touch /var/setrootpassword"
  not_if {File.exists?("/var/setrootpassword")}
end

cookbook_file "mysqlcommands" do
  source 'mysqlcommands'
  path "/tmp/mysqlcommands"
  not_if {File.exists?("/tmp/mysqlcommands")}
end

execute "setpassword" do
  command "mysql -uroot -prootpassword < /tmp/mysqlcommands && touch /var/setpassword"
  not_if {File.exists?("/var/setpassword")}
end

cookbook_file "latest.zip" do
  source 'latest.zip'
  path "/tmp/latest.zip"
  not_if {File.exists?("/tmp/latest.zip")}
end

execute 'unzip' do
  command 'unzip /tmp/latest.zip'
  cwd '/var/www/html/'
  not_if { File.exists?("/var/www/html/wordpress/index.php") }
end

cookbook_file "wp-config-sample.php" do
  source 'wp-config-sample.php'
  path "/tmp/wp-config-sample.php"
  not_if {File.exists?("/tmp/wp-config-sample.php")}
end

remote_file '/var/www/html/wordpress/wp-config.php' do
 source  'file:///tmp/wp-config-sample.php'
end

directory '/var/www/html/wordpress' do
  mode '0775'
  owner 'www-data'
  group 'www-data'
end

service "apache2" do
  action :restart
end
# For more information, see the documentation: https://docs.chef.io/essentials_cookbook_recipes.html
