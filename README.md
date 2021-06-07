# README



## Local Setup
Dependent services run via `docker-compose`, while the rails/sidekiq portions run on your local device.

### Dependent services
Install `docker` and `docker-compose`. You'll need access to the organization Docker Cloud, specifically rocketcyber/socket_proxy.

`$ docker login`
`$ docker-compose pull`
`$ docker-compose up`

Install PostgreSQL and add user

`$ brew install postgresql`

```sh
$ psql postgres
postgres=# CREATE USER postgres WITH PASSWORD '' CREATEDB SUPERUSER NOCREATEROLE;
postgres=# \quit
```

`$ brew services start postgresql`

### Setup ENV vars

The project uses [direnv](https://github.com/direnv/direnv) to automatically load ENV vars for the project. Install it.

Copy `.envrc.sample` to `.envrc`. Update the blank values from a team member.

`$ direnv allow .`

### Install gems

`$ bundle install`

### Install yarn packages
We use Webpack/Webpacker to manage front-end assets via `yarn`. Assumes you have nodejs installed.

`$ npm -g install yarn`
`$ yarn install`

### Seed the database
`$ bin/seed`

### Add host entry for test domain

example.com needs to resolve to localhost. This is required for S3 CORS rules used by client side file uploading.

`$ sudo sh -c "echo '127.0.0.1       example.com' >> /etc/hosts"`

### Run tests

`$ rspec`

or run automaticaly as you write code (along with rubocop and livereload)

`$ bundle exec guard`

or to run the entire test suite quickly, in [parallel](https://github.com/grosser/parallel_tests), use the `bin/pspec` command.

Setup:
```sh
$ rails parallel:create

# After migrations
$ rails parallel:prepare
```

Run:
`$ bin/pspec`

### HTTP Access
Much of the application depends on public HTTP(s) access (running agents, client-side file uploads). Use of ngrok.io to proxy traffic to an SSL endpoint is recommended. Two tunnels are needed, here are some examples:
```yml
# ~/.ngrok2/ngrok.yml
authtoken: YOUR_AUTH_TOKEN
json_resolver_url: ""
dns_resolver_ips: []
tunnels:
  dwconsole:
    proto: http
    addr: 3001
    hostname: dwconsole.ngrok.io

  wsdwconsole:
    proto: http
    addr: 8080
    hostname: ws.dwconsole.ngrok.io
```

The corresponding env vars would be:

```sh
export HOST=dwconsole.ngrok.io
export ASSET_HOST=https://dwconsole.ngrok.io
export AGENT_WS_HOST=ws.dwconsole.ngrok.io
export SOCKET_PROXY_SECRET=secret
```

### Errors
You may see some errors after you first load the dashboard. If the error is related to missing TTPs, go ahead and run this in your terminal:
```sh
bin/rails ttps:add_missing
```

Reload your browser. The error should now be corrected.

### Whoa, that's a lot.
Let's get things runnable with a single command. This section is only required for maintaining your sanity. When completed this will run your docker instances, a rails web server, a sidekiq background worker, and start ngrok for you. It will also shut them all down when you're done.

#### Foreman
Foreman will run a number of processes for us with a single command.

`$ gem install foreman`

Copy the `.foreman.sample` file to `.foreman`.
Copy the `personal.Procfile.sample` to `personal.Procfile`. Update the ngrok hosts to match yours.

Ensure your docker instances and rails servers aren't running, then type `start`. The entire app should then spin up automatically.
