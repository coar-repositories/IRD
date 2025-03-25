# IRD

## Running locally
### Requirements
1. Local Postgres Server, with a user account capable of creating databases
2. Local Opensearch server
2. Ruby environment (tested with 3.3.7)

### Process
(from this directory)
1. `bundle install`
2. Copy the `template.env` file and name this copy `.env`
3. Edit the ENV variables in the file `.env` appropriately
4. `rails db:create`
5. `rails db:migrate`
6. `rails db:seed`
7. `rails server`

## Reindexing
`bundle exec thor index:reindex`

## Running
`rails server`
