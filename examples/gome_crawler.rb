# coding: utf-8
require 'gome'

gc = Gome::Crawler.new(interval: 0)
gc.before_fetch { |*args| STDERR.puts "[#{Time.now}] #{args}" }
gc.get('http://www.bing.co.jp/search', q: '日本語').search('.b_algo h2 a').each do |anchor|
  puts "label: #{anchor.text}"
  puts "title: #{gc.get(anchor[:href]).title}"
end
