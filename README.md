# capistrano-ec2-utils

Capistrano plugin providing some useful utilities for interacting with EC2.
Currently only provides management of security group ports.

NOTE: Uses Version 1 of the AWS SDK gem.

## Installation

Add the gem to your `Gemfile` and run `bundle install`:

```ruby
group :development do
  gem 'capistrano-ec2-utils', github: 'elevation/capistrano-ec2-utils'
end
```

Then add the gem to your `Capfile`:

```ruby
require 'capistrano/capistrano-ec2-utils'
```

## Configuring

### Via YAML

AWS credentials will attempt to load from `config/aws.yml` by default and
should be grouped by environment - the same format as the aws-sdk gem uses.

You can change the path to the yaml file if required:

```ruby
set :ec2_config, "config/ec2.yml"
```

### Via Capistrano config

```ruby
set :ec2_access_key_id,     "YOUR_ACCESS_KEY"
set :ec2_secret_access_key, "YOUR_SECRET_ACCESS_KEY"
set :ec2_security_group,    "YOUR_EC2_SECURITY_GROUP"
```

You can also optionally configure security group ports that are managed
or your aws region

```ruby
set :ec2_ports, [2222]        # defaults to [22]
set :ec2_region, 'us-west-2'
```

## Usage

```
cap production ec2:allow_ip     # opens ports for your current ip
cap production ec2:revoke_ip    # closes ports for your current ip
cap production ec2:cleanup_ips  # closes ports for all ips except your current ip
```

## Todo

1. Allow configuration via yaml file
2. Support region config
3. Publish rubygem
4. Add some tests
