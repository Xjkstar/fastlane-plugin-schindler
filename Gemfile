source('https://rubygems.org')

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

# 用 VSCode 调试需要加上下面两句
gem 'ruby-debug-ide'
gem 'debase'