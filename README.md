# schindler plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-schindler)


## About Schindler

Schindler is a TestFlight automatic processing tool, which is used to maintain the number of TestFlight quota, eliminate useless testers, and improve the external gray effect of iOS.

## Change Log

| Date | Version | Content |
|--|--|-------|
| 2023-08-10 |1.1.0| 1. Adapts to App Store Connect API 2.4|
||| 2. Remove only Publick link testers, as email tester cannot be removed|
||| 3. No more deleting Unused testers|
||| 4. Multi-group account friendly, providing optional parameters Developer Portal Team ID, App Store Connect Team ID|
||| 5. Full English log|
| 2022-09-30 |1.0.1| 1. Remove TestFlight testers that are not actually testing your app, support the following 3 categories: Uninstall, Expired, Unused|


## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-schindler`, add it to your project by running:

```shell
fastlane add_plugin schindler
```

## RubyGems

[fastlane-plugin-schindler](https://rubygems.org/gems/fastlane-plugin-schindler)


## Example
### 1. Fastlane Ready
```shell
# install fastlane
gem install fastlane
# create a workspace
fastlane init
# add puglin
fastlane add_plugin schindler
```

### 2. Edit Fastfile
After Init succeeds, the fastlane folder will be generated in the current directory. 

Edit ./fastlane/Fastfile，for example: 
```ruby
# A sample Fastfile
lane :delete do
  schindler(
    filter_type: "3",                   # Optional, '1'-Not installed, '2'-Expired, '7'-All(1 | 2), default 3
    auto_confirm: "auto",               # Optional, 'auto'-skip, default no. Skip the second confirmation, or wait for user confirmation before deleting after scanning
    user_id: "xjk_001@163.com",         # Your AppID for login App Store Connect
    user_password: "********",          # Optional, AppID password
    ios_app_id: "11112222",             # The ID of the app in the Apple Store
    portal_team_id: "my_team_id",       # Optional, Developer Portal Team ID
    itc_team_id: "my_itc_team_id"       # Optional, App Store Connect Team ID
  )
end

```

### 3. Execute
```bash
fastlane delete
```
![result](https://github.com/Xjkstar/fastlane-plugin-schindler/blob/master/Assert/demo1.jpg)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Extras(important by 08/10/2023)
Due to changes in App Store Connect API 2.4, beta_tester_metrics for betaTesters in Spaceship are invalid, resulting in Tester status information no longer being available.

Based on the betaTesters interface (appstoreconnect.apple.com/iris/v1/betaTesters), I updated this repository. And submitted the commit to fastlane.

Consider that it takes time and days for the commit to go through, so while waiting for it to go through, if you get an error running this script, scroll down.

### Find local fastlane
First, we need to find the betaTesters file in the local fastlane

```shell
# Get local gem folder path
which fastlane
# Assuming that the previous step yields '/Users/hongtao/.mtl-cli-env/gems/bin/fastlane'

# Further find the specific fastlane version, note that here you need to open the gem folder by deleting the path to fastlane (replace '/bin/fastlane' at the end with '/gems') and then append the path to gems (/gems).
open /Users/hongtao/.mtl-cli-env/gems/gems

# After opening finder, find the latest local version of fastlane, for example, the author's local is fastlane-2.214.0, drag this folder to the terminal window and append '/spaceship/lib/spaceship/connect_api/models/beta_tester.rb' to the end. , and then open this file
open /Users/hongtao/.mtl-cli-env/gems/gems/fastlane-2.214.0/spaceship/lib/spaceship/connect_api/models/beta_tester.rb
```

### Modify local fastlane
Second, we need to manually modify the betaTesters property in the local fastlane

before modification
```ruby
require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaTester
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :invite_type
      attr_accessor :invitation

      attr_accessor :apps
      attr_accessor :beta_groups
      attr_accessor :beta_tester_metrics
      attr_accessor :builds

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "inviteType" => "invite_type",
        "invitation" => "invitation",

        "apps" => "apps",
        "betaGroups" => "beta_groups",
        "betaTesterMetrics" => "beta_tester_metrics",
        "builds" => "builds"
      })

      ......
```

after modification
```ruby
require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaTester
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :invite_type
      attr_accessor :invitation

      attr_accessor :apps
      attr_accessor :beta_groups
      attr_accessor :beta_tester_metrics
      attr_accessor :builds

      # add by xjkstar 2023-08-09
      attr_accessor :isDeleted
      attr_accessor :beta_tester_state
      attr_accessor :last_modified_date
      attr_accessor :installedCfBundleShortVersionString
      attr_accessor :installedCfBundleVersion
      attr_accessor :removeAfterDate
      attr_accessor :latestExpiringCfBundleShortVersionString
      attr_accessor :latestExpiringCfBundleVersionString
      attr_accessor :installedDevice
      attr_accessor :installedOsVersion
      attr_accessor :installedDevicePlatform
      attr_accessor :installedAppPlatform

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "inviteType" => "invite_type",
        "invitation" => "invitation",

        "apps" => "apps",
        "betaGroups" => "beta_groups",
        "betaTesterMetrics" => "beta_tester_metrics",
        "builds" => "builds",

        # add by xjkstar 2023-08-09
        "isDeleted" => "isDeleted",
        "betaTesterState" => "beta_tester_state",
        "lastModifiedDate" => "last_modified_date",
        "installedCfBundleShortVersionString" => "installedCfBundleShortVersionString",
        "installedCfBundleVersion" => "installedCfBundleVersion",
        "removeAfterDate" => "removeAfterDate",
        "latestExpiringCfBundleShortVersionString" => "latestExpiringCfBundleShortVersionString",
        "latestExpiringCfBundleVersionString" => "latestExpiringCfBundleVersionString",
        "installedDevice" => "installedDevice",
        "installedOsVersion" => "installedOsVersion",
        "installedDevicePlatform" => "installedDevicePlatform",
        "installedAppPlatform" => "installedAppPlatform"
      })

      ......
```

### Let's go
Changes complete, up and running

```shell
fastlane delete
```


## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
