## Chef Demo

This repository is meant to help you get started using Chef to provision Amazon EC2 instances. Cookbooks are included to provision an Ubuntu server with Apache, Passenger, and MySQL to accommodate a fully-deployed Rails 3 application.

To get started, follow these steps:

1) Sign up for Opscode's Hosted Chef at: http://www.opscode.com/hosted-chef/

2) From Hosted Chef, generate a private key, validation key, and knife config. Modify `.chef/knife.rb` to match the generated knife.rb, and copy the two keys into `.chef/` (name them per your knife.rb).

3) Modify `.chef/knife.rb` to specify your Amazon EC2 access key ID, secret access key, and SSH key ID (if you haven't already, you'll need to generate an EC2 key pair and configure your SSH client to use it).

4) Create a data bag for your application and place it in `data_bags/apps/` (use quoter.json as an example). Modfiy `site-cookbooks/demo_app_server/recipes/default.rb` to specify the name of your new data bag.

5) Upload all cookbooks, data bags, environments, and roles to the Chef server:

```console
knife cookbook upload -a

knife data bag create apps
knife data bag from file apps quoter.json

knife environment from file environments/qa.rb
knife environment from file environments/staging.rb
knife environment from file environments/production.rb

knife role from file roles/base.rb
knife role from file roles/app_server.rb
knife role from file roles/db_server.rb
```

6) If you haven't already, configure your EC2 security groups to allow inbound SSH and HTTP access. The easiest option is to simply modify the default security group that already exists.

7) Finally, provision a new EC2 instance. Specify the roles, environment, and name you'd like the new node to have:

```console
knife ec2 server create -x ubuntu -r 'role[base],role[db_server],role[app_server]' -E production -N quoter
```
