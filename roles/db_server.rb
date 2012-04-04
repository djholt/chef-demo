name "db_server"
run_list "recipe[mysql::server]"
override_attributes "mysql" => { "server_root_password" => "", "socket" => "/tmp/mysql.sock" }
