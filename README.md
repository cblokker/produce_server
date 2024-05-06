## Summary of thought process

I aimed to develop a production-level rails app, to showcase both ruby and rails knowledge. Although there wasn't a requirement for an API layer, controllers can easily be built out with the service objects in place, if needed. The models are backed by PostgreSQL tables. For formulating the algorithm, I opted for an SQL approach to simulate a real-world matching query, that may be found in a complex data schema. I introduced additional features such as quantity and prices, enabling users to create orders across multiple sellers. I also bundled the concepts of buyer and seller into a single table, envisioning a scenario where a seller could also act as a buyer, similar to the functionality on Airbnb - where a host can also make bookings.

I adopted a 'Service Object' approach in the application's design to declutter the models, define actions in an understandable namespace, and to facilitate future composition of service objects with actions across multiple models. I avoided Active Record callbacks, and placed that logic in the service objects, to ensure the app does not get entangled in unexpected callback behavior.

I aslo created a table view, which could be extended into a materialized view (depending on requirements), to capture the concept of "next_created_at" to compare across a buyers produce orders, to be used in both seller and buyer query objects.

WIP:
- **`OrderService::CancelOrder`** and **`OrderService::CancelOrderDetail`** specs!
- Test against large datasets for query performance, to be able to perform updates & optimizations for the query objects & table view.



## Overview of app

#### Models
- [User](https://github.com/cblokker/produce_server/blob/main/app/models/user.rb)
- [Order](https://github.com/cblokker/produce_server/blob/main/app/models/order.rb)
- [OrderDetail](https://github.com/cblokker/produce_server/blob/main/app/models/order_detail.rb)
- [InventoryItem](https://github.com/cblokker/produce_server/blob/main/app/models/inventory_item.rb)
- [Produce](https://github.com/cblokker/produce_server/blob/main/app/models/produce.rb)

#### Service Objects
- [OrderService::PurchaseOrder](https://github.com/cblokker/produce_server/blob/main/app/services/order_service/purchase_order.rb)
- [OrderService::CancelOrder](https://github.com/cblokker/produce_server/blob/main/app/services/order_service/cancel_order.rb)
- [OrderService::CancelOrderDetail](https://github.com/cblokker/produce_server/blob/main/app/services/order_service/cancel_order_detail.rb)

#### Query Objects
- [UserQueries::MatchBuyerToSellers](https://github.com/cblokker/produce_server/blob/main/app/queries/user_queries/match_buyer_to_sellers.rb)
- [UserQueries::MatchSellerToBuyers](https://github.com/cblokker/produce_server/blob/main/app/queries/user_queries/match_seller_to_buyers.rb)

#### Table Views [scenic gem](https://github.com/scenic-views/scenic)
- [buyer_produce_orders](https://github.com/cblokker/produce_server/blob/main/db/views/buyer_produce_orders_v01.sql)

#### Misc
- [Seed File](https://github.com/cblokker/produce_server/blob/main/db/seeds.rb) - to have some test data to play with in `rails c`. Note that it isn't very idempotent.


## SETUP

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




