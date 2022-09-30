# Publishing your plugin
## RubyGems
The recommended way to publish your plugin is to publish it on RubyGems.org. Follow the steps below to publish your plugin.

1. Create an account at [RubyGems.org](https://rubygems.org/)
2. Publish your plugin to a [GitHub](https://github.com/) repo
3. Update the fastlane-plugin-[plugin_name].gemspec file so that the spec.homepage points to your github repo.
4. Publish the first release of your plugin:

```
gem signin
bundle install
rake install
rake release
```
5. Edit ./fastlane/plugin/schindler/version when publich one more time

Now all your users can run fastlane add_plugin [plugin_name] to install and use your plugin.

## GitHub
If for some reason you don't want to use RubyGems, you can also make your plugin available on GitHub. Your users then need to add the following to the Pluginfile

```
gem "fastlane-plugin-[plugin_name]", git: "https://github.com/[user]/[plugin_name]"
```
