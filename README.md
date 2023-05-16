# guard-srb

[![Gem Version](https://badge.fury.io/rb/guard-srb.svg)](https://badge.fury.io/rb/guard-srb)

**guard-srb** allows you to automatically typecheck Ruby code [Sorbet](https://sorbet.org) when files are modified.

Tested on MRI 2.7 - 3.2.

## Installation

Please make sure to have [Guard](https://github.com/guard/guard) installed before continue.

Add `guard-srb` to your `Gemfile`:

```ruby
group :development do
  gem 'guard-srb'
end
```

and then execute:

```sh
$ bundle install
```

or install it yourself as:

```sh
$ gem install guard-srb
```

Add the default Guard::Srb definition to your `Guardfile` by running:

```sh
$ guard init srb
```

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Options

You can pass some options in `Guardfile` like the following example:

```ruby
guard :srb, all_on_start: false, cli: ['--ignore=tmp/', '--ignore=vendor/'] do
  # ...
end
```

### Available Options

```ruby
all_on_start: true     # Check all files at Guard startup.
                       #   default: true
cli: '--ignore=tmp/'   # Pass arbitrary Sorbet CLI arguments.
                       # An array or string is acceptable.
                       #   default: nil
cmd: './bin/srb'       # Pass custom cmd to run sorbet.
                       #   default: srb

hide_stdout: false     # Do not display console output (in case outputting to file).
                       #   default: false
notification: :failed  # Display Growl notification after each run.
                       #   true    - Always notify
                       #   false   - Never notify
                       #   :failed - Notify only when failed
                       #   default: :failed
config: true           # Use default config at `sorbet/config`
                       #   default: false
colorize: "auto"       # Colorize sorbet output
                       # One of "always", "auto", "never"
                       #   default: "always"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dmitryzuev/guard-srb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dmitryzuev/guard-srb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Guard::Srb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dmitryzuev/guard-srb/blob/main/CODE_OF_CONDUCT.md).
