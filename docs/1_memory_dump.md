# Architecture

The Core of RC is the Console app, a rails application that manages all agent communication, reporting, alerting, etc. Spread out across the world
are rocketagents running on endpoint devices. The rocketagents communicate with the Console via REST API and realtime Websockets.

## RocketAgents

Rocketagents are C++ programs, scripted with Lua. The agents themselves are self bootstraped and updated via the console REST API in combination with S3.
See Administration > Support Files and Agent Releases.

Rocketagents authenticate and register with a unique customer license key. When registering, the device provides a unique fingerprint represented as a
hash, which is then used for any device specific API calls for authentication.

Rocketagents rely on the REST API for communication with the console that needs to be confidently relayed. Non-critical data transfer takes place
via websocket. See the [rocketcyber/socket_proxy](https://github.com/rocketcyber/socket_proxy) project for details.

## Data Structures (Models mostly)

### Accounts
The core data structure in the Console application is `Account`, and its STI children `Provider` (sometimes refered to as an Managed Service Provider -- MSP), and `Customer`. Accounts are a tree structure leveraging `ltree` and the `path` attribute. There can be `n` levels in the tree, but typically there are three structures:

Basic MSP
+ Provider
  + Customer
  + Customer
  + ...

Distributor model
+ Distributor
  + Provider
    + Customer
    + ...
  + Provider
    + Customer
    + ...
  + ...

Or the worst kind, a blend of the two for the sole purpose of multiple subscriptions to different plans at the same time.
+ Root Provider
  + Provider (Pro Plan)
    + Customer
    + ...
  + Provider (Managed Plan)
    + Customer
    + ...

Accounts have tree like descendants via the `LtreeManyable` concern. This allow other records to belong to the tree like structure and be queryable. For example, this allow us to find all `Apps::Result` records that are in a Distributor tree, or just one of the Distributor's providers, etc.

### Apps::Config
Most of the apps allow configuration on a per-account and device basis. We provide a default configuration, and then following the account's tree-like definition, supports inheritance for changes made at lower levels (sub-provider, Customer, device).

Given the following configs:

```
# Root account app config
{
  "foo": "bar",
  "baz": true,
  "exclusions": []
}

# Customer account app config
{
  "foo": "bang",
  "exclusions": [
    "good.exe"
  ]
}

# Device A's app config
{
  "baz": false,
  "exclusions": [
    "othergood.exe"
  ]
}

```

the device's resulting app config would be:

```
{
  "foo": "bang",
  "baz": false,
  "exclusions": [
    "good.exe",
    "othergood.exe"
  ]
}
```

### Apps::Result
Apps::Result is our money model. With some STI sub-classes (Apps::DeviceApp, etc), these records indicate results the app has detected (either by a device or cloudapp context).

Related models are `App`, `Apps::Incident`, `Apps::CounterCache`, and a few others. The meat of these records is the `details` JSONB column, which _should_ contain `TestResult` schema adhering JSON structures.

### Test Results
The `TestResults::BaseJson` and its subclasses are wrappers for Hunt Result and App Result JSON. "Why a wrapper for JSON," you say? Historically result JSON has been wildly inconsistent in data and format from result to result even in the same app. These wrappers help normalize and abstract that inconsitency, allow us to define a method that pulls out all the possible values in all the possible locations, instead of doing that manually in all the code that touches result data.

The TestResult schema is: It must declare a `type` attribute, which is a string to map to a `TestResults::BaseJson` sub-class, and an `attributes` object with the actual attributes for the result. If no sub-class is defined as a ruby class, `TestResults::BaseJson` will be used. There are also some convienence methods for typecasting dates and such.

Given this results
```json
[{
  "type": "Foo",
  "attributes": { "created_at": 1234566 }
},
{
  "type": "Foo",
  "attributes": { "manifested_at": 1234566 }
},
{
  "type": "Foo",
  "attributes": { "lol": "no date" }
}]
```

and the given ruby class

```ruby
module TestResults
  class FooJson < BaseJson
    def creation_date
      created_at || manifested_at || 1.month.ago
    end
  end
end
```

Each of the results would provide a result with `test_result_json.creation_date`.

Nested schema adhering objects will also be instantiated as a `TestResults::BaseJson` if possible.

### Apps::CounterCaches

Apps::CounterCaches are a custom implementation to keep track of the number of Apps::Results for a given app, at a given account path, with a given verdict, for a given device (optional). This means that there will be many counter cache records depending on the scope you’re accessing (a device’s counter caches, an accounts, an apps, a verdicts, or a combination of these). While this may sound like a lot, doing a sum(:count) on these is faster than trying to count 1M+ records with the same filter parameters. The vast majority of the code around counter cache creation, incrementing, etc lives here: https://github.com/rocketcyber/console/blob/master/app/models/apps/result.rb#L85-L152

### Hunts
Hunts are the implementation of Threat Hunting in the console. Given a set of hunting criteria, the console dynamically generates a Lua script which the agent can download via the REST API. Once the agent has its results, it uploads the result data to S3 (using direct signed uploads) and then submits a POST with the upload_id and some other metadata. The console then runs the results through a processor which creates the needed data models to represent the positive or negative results.

Hunts, in their current implementation, are needlessly complex due to prior requirements. The implementation of Continuous Hunts, Feeds, and very detailed result data still exist, however, almost none of it is used (or used well).

### Hunt
A hunt represents 1 or more tests that should be evaluated on one or more devices. Since a `Hunt` is editable, it has a revision.  This allows end users to implement an iteration/evaluation loop to find the information they want.

### Hunts::Test
A hunt test represents one or questions that need to be answered on a given device. A hunt test may have many conditions. In plain English, "Does this device have a filename which meets condition X".

### Hunts::Condition
Hunt conditions are a way for end users to evaluate a conditions result. Think `==`, `>=`, `!=` `~`, etc. There may be many conditions per test.

### HuntResult
Represents the result of a device's evaluation of a hunt. Direct relationship to the hunt, device that produced this result, an upload representing the result data, and many test results.

### Hunts::TestResult
The results of each and every hunt test is recorded in the database, connecting a positive hunt result to specific condition checks. This was implemented such that deep analytic queries should be performed in reports that no longer exist.

### Devices::QueuedHunt
Given a device, how do we know if it needs to run a hunt? Because a hunt targets device `Group`s and can be re-run with the same revision, can be edited (which would generate new revisions), and may exist thousands of times, a simple SQL query became a bottleneck. Enter this model, which represents hunts that a device needs to run.

### Hunts::Feed
Hunt Feeds are hunts generated from an external source which provides the hunt tests and conditions for us to automatically generate. An example of this might be a source of known-bad file hashes, IPs, or a YARA script. Since feeds can be filtered/scoped (or used to be) they are unique per subscription, resulting in unique feed results, hunts, hunt tests, hunt conditions, hunt result, etc etc.

### Hunts::FeedResult
A feed result joins a hunt generated by a feed.
