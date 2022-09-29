# schindler plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-schindler)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-schindler`, add it to your project by running:

```bash
fastlane add_plugin schindler
```

## About schindler

Schindler is a TestFlight automatic processing tool, which is used to maintain the number of TestFlight quota, eliminate useless testers, and improve the external gray effect of iOS.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

```ruby
# A sample Fastfile
lane :test do
  schindler(
    filter_type: "7",                   # Optional, '1'-Not installed, '2'-Expired, '4'-Unused, '7'-All(1 | 2 | 4), default 7
    auto_confirm: "auto",               # Optional, 'auto'-skip, default no. Skip the second confirmation, or wait for user confirmation before deleting after scanning
    user_id: "xjk_001@163.com",         # Your AppID for login App Store Connect
    user_password: "********",          # AppID password, support App private password
    ios_app_id: "11112222"              # The ID of the app in the Apple Store
  )
end

```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
