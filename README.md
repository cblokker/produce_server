# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



Create Postgres role
`sudo postgres`
`psql`
`create role produce_marketpalce_api with createdb login password 'password1';`
exit out of cli

Run the following to create db, migrate db, and seed dev environment with some data to play with.
`rails db:drop db:create db:migrate`


Things to ponder:

1. Storing Currency (3-letter ISO 4217 currency code) and currency conversions for internationlization.
2. Storing unit of weight and weight conversions for internationlization.
3. Using decimal instead of int for more granular precition of weight, based on business use case (and for unit conversions).
4. Add quantities on a per unit level
5. Adding AASM gem to encapuslate state machine logic for orders.
6. 