# Guardian

A web interface for running your own certificate authority. Ideal for generating
certificates for internal-use only.

## Requirements

* Ruby 2.3 or higher
* Bundler
* MySQL database (configured in `config/guardian.yml` once cloned)

## Installation

1. `git clone https://github.com/adamcooke/guardian`
2. `cd guardian`
3. `bundle`
4. `bundle exec rake db:schema:load guardian:create_initial_user`
5. `bundle exec rails server

## Upgrade

1. `cd guardian`
2. `git pull`
3. `bundle`
4. `bundle exec rake db:migrate`
5. Restart web server

## TODO

* Support for revocation lists
* A UI would be nice
