# coding: utf-8
require 'gome'

puts Gome::Agent.new.get('https://www.bing.co.jp/search', q: '日本語').at('title').text
puts Gome::Agent.new.get('http://htaccess.cman.jp/sample/access_referer/sample.jpg').code
puts Gome::Agent.new(force_encode: true).get('http://www.alphapolis.co.jp/manga/viewOpening/607000106/').at('.shere_line+ul>li:first-child span').text
ga = Gome::Agent.new(force_encode: true, allow_error_codes: %w(403))
page = ga.get('http://www.alphapolis.co.jp/manga/viewOpening/455000131/')
p page.at('.title_area h2').nil?
value = page.at('input[onclick^="eternityConfirm"]')[:onclick].match(/\((\d+)\)/)[1]
ga.add_cookie('confirm', value)
puts ga.reload.at('.title_area h2').text
