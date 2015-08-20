# Grape::Knock

Use [Knock](https://github.com/nsarno/knock) with [Grape](https://github.com/ruby-grape).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-knock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-knock

## Usage

Mount the middleware in your API:

```ruby
class MyApi < Grape::API
  format :json

  use Grape::Knock::Authenticable
end
```

The gem will raise `Grape::Knock::ForbiddenError` when authentication failed. You can rescue this exception in your API
in order to respond with a `403 Forbidden` http request:

```ruby
class MyApi < Grape::API
  format :json

  use Grape::Knock::Authenticable

  rescue_from Grape::Knock::ForbiddenError do
    error!('403 Forbidden', 403)
  end
end
```

## Authentication

The gem expect to find your JWT token in the request `Authorization` header. For example using curl:

```
curl -H "Authorization=Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.e30.BwE63vgb2KmmcUznvFOxKTOtkMNwAoR5yX4MrtydyXc" http://api.com/resource
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grape-knock.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

