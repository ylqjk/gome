# coding: utf-8
require 'gome'
require 'pp'

class BingSearchPage < Gome::Page
  rule err: proc { raise }
  rule uri: proc { uri },
       title: one('title'),
       query: one('#sb_form_q', :name),
       count: one('.sb_count') { text.gsub(/,/, '').match(/^[0-9]+/)[0].to_i },
       results: many('.b_algo h2') { one('a') { { text: text, href: self[:href] } } }
end

gc = Gome::Crawler.new(interval: 0)
gc.before_fetch { |*args| STDERR.puts "[#{Time.now}] #{args}" }
gc.start('http://www.bing.co.jp/search', q: '日本語') do |*args|
  pp get(*args, &BingSearchPage.extractor)
end
