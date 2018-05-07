# Pressy

Pressy lets you work with your WordPress site as though you were using a static site generator like [Jekyll](https://jekyllrb.com).

## Installation

Pressy is a work-in-progress and is not yet published as a RubyGem.

<!--

You can install Pressy using RubyGems:

    $ gem install pressy

This will install the `pressy` command-line tool.
-->

## Usage

### Initializing a new site directory

Before you can use Pressy, you need to set up a directory to hold the files for your site.

    $ mkdir example.com
    $ cd example.com
    $ pressy init
    # TODO output from init

This will create a `.pressy/config.yml` file in the `example.com` directory. This configuration will allow subsequent `pressy` commands to connect to your WordPress site.

### Pulling changes from WordPress

To sync the contents of your posts on WordPress to your local directory, you can run `pressy pull`.

    $ pressy pull
    Updated 5 posts.

```
TODO more commands
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mjm/pressy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pressy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mjm/pressy/blob/master/CODE_OF_CONDUCT.md).
