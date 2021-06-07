# Testing
Tests are writen with RSpec.

## Run a single test

`$ bundle exec rspec spec/models/account_spec.rb`

## Run all tests (slow version)

`$ bundle exec rspec`

## Run all tests (fast version)

Run the tests in parallel, utilizing all your cores/treads.

1. Setup the parallel test dbs. Each thread uses its own db. This only needs to be done once or after a db schema change.
`$ rails parallel:prepare`

2. Hold on to yer butts
`$ bin/pspec`

## Run tests automatically as you write code/tests

`$ bundle exec guard`

# Codestyle
Codestyle is enforced on CI.

## Ruby codestyle
`$ bundle exec rubocop`

Consider using the `--parallel` for faster enforcement, or `-a` for autofixes (fix indentation etc).

## Javascript codestyle

`$ ./node_modules/.bin/eslint app/javascript/**/*.js`

Consider using `--fix` for autofixes.
