release: DB_STATEMENT_TIMEOUT=0 jemalloc.sh bundle exec rails db:migrate
web: jemalloc.sh bundle exec puma -C config/puma.rb
worker: jemalloc.sh bundle exec sidekiq -C config/sidekiq.yml
