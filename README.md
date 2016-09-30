# 18F Micropurchase Notifier

[![Build Status](https://semaphoreci.com/api/v1/ulfmagnetics/18f-micropurchase-notifier/branches/master/badge.svg)](https://semaphoreci.com/ulfmagnetics/18f-micropurchase-notifier)

18F, a branch of the US Digital Service, launched a
["micropurchasing"](https://18f.gsa.gov/2015/10/13/open-source-micropurchasing/)
experiment last year, allowing interested developers to bid on small software
engineering jobs via reverse auctions starting at $3,500.

This app's job is to ensure that a user is always notified when new auctions
appear on the site. It uses the Micropurchasing platform's
[API](https://micropurchase.18f.gov/api) and requires a Github Personal API
token. See the API documentation for more details.

## Prerequisites

- A Sendgrid API key for sending email notifications
- A Redis instance (I use the free [RedisCloud Heroku add-on](https://elements.heroku.com/addons/rediscloud))
- A [Github personal API token](https://github.com/blog/1509-personal-api-tokens) (optional, not currently required to fetch auctions via the 18F API)

## Installation

```
git clone https://github.com/ulfmagnetics/18f-micropurchase-notifier
cd 18f-micropurchase-notifier
bundle install
cp .env.example .env
# Edit .env and set required variables
bundle exec puma -C config/puma.rb
```

## Usage

The app will store the "last checked" timestamp in redis, and when accessed via
HTTP will check the API for any new auctions and will send notification emails
to all addresses in the comma-separated `EMAILS_TO_NOTIFY` environment variable
if any new auctions are found. The intended use case is to set up a ping
service (such as Pingdom or New Relic) and use it to ping the app periodically,
e.g. daily.

I am running this app on a free-tier Heroku dyno with the Sendgrid and
Rediscloud add-ons provisioned.

