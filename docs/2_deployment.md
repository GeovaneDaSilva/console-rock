# Deployment

The console app is hosted on heroku. Deployment is simple and automatic.

`rocketcyber-staging` automatically deploys successful builds of the `master` branch

`rocketcyber-production` automatically deploys successful builds of the `prod` branch

Typically, a developer should verify functionality in `dev` locally --and maybe with a heroku review app-- before merging a PR into `master`. 

When ready to deploy to production, simply merge the `master`
branch into the `prod` branch. It will build in CircleCI and deploy automatically.  

NOTE -- it is generally assumed that anything on `master` is ready to be deployed to `prod`.  If you would like to test something on `staging`, make sure any other developers are aware that should not be included in any deployments.
