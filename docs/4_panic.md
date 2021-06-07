# Shit's broken, where do I start?
First, open up all the below links. They'll either tell you what's wrong or help you identify what is wrong.

Common causes of outages:

1. Lots of web load
2. Lots of backed up background jobs
3. A poorly performing db query


## Lots of load
The Heroku Web metrics would give you a hint as to change in web load. 

Is a customer deploying a large number of agents?

Generally, cranking up the number of web dynos would be the best option here. However, there is an upper limit to the number of connections to the database & Redis instaces that can be made (400 as of this writing). This is web dynos + worker dynos + rails console connections.

As of right now, each web dyno consumes `up to 160 connections`.
As of right now, each web dyno consumes `up to 20 connections`.

If you start seeing Sentry errors about not being able to obtain a db connection, you've scaled too far.

## Backed up background jobs

This usually happens when a particular type of job takes a very long time to run (more than a few seconds). This will effectively back up and halt background job execution. The best cure is to solve the problem with the job in question, or disable it entirely.

## Links
[Heroku Metrics](https://dashboard.heroku.com/apps/rocketcyber-production/metrics/web)

[https://app.rocketcyber.com/administration/sidekiq/](https://app.rocketcyber.com/administration/sidekiq/)

[https://app.rocketcyber.com/administration/pghero](https://app.rocketcyber.com/administration/pghero)

[LogDNA](https://app.logdna.com)

[Skylight](https://skylight.io/app)
