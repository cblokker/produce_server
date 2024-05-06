##### Prerequisites

The setups steps expect following tools installed on the system.

- Ruby 3.1.2
- Rails 7.1.3.2
- PostgreSQL 14.11

##### 1. Check out the repository & bundle

```bash
git clone https://github.com/cblokker/produce_server.git
```

```bash
bundle install
```

##### 2. Create postres role. [A reference](https://www.digitalocean.com/community/tutorials/how-to-set-up-ruby-on-rails-with-postgres)
 - a) For PostgreSQL server, run:
   ```bash
   sudo postgres
   ```
 - b) For PostgreSQL interactive terminal, run:
   ```bash
   psql
   ```
 - c) Run the following command in the interactive terminal:
 
   ```bash
   create role produce_marketpalce_api with createdb login password 'password1';
   ```


##### 3. Create and setup the database

Run the following commands to create and setup the database, including some seed data to play around with.

```ruby
rails db:create db:migrate db:seed
```

##### 4. Run the tests


```ruby
bundle exec rspec
```

##### 5. Server not needed for this example.


