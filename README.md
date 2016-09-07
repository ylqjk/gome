# Gome

Gome is tiny crawler framework.

## Start

1. Add Gome to your `Gemfile` and `bundle install`:

   ``` ruby
   gem 'gome', git: 'https://github.com/ylqjk/gome.git'
   ```

2. Load and launch Gome:

   ``` ruby
   require 'gome'

   gc = Gome::Crawler.new(interval: 0)
   gc.before_fetch { |*args| STDERR.puts "[#{Time.now}] #{args}" }
   gc.get('http://example.tld/')
   ```
