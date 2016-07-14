# coding: utf-8
require 'test_helper'

class GomeAgentTest < Minitest::Test
  def test_request_simple_get
    assert { '日本語 - Bing' == Gome::Agent.new.get('https://www.bing.co.jp/search', q: '日本語').at('title').text }
  end

  def test_request_with_self_referer
    assert { '200' == Gome::Agent.new.get('http://htaccess.cman.jp/sample/access_referer/sample.jpg').code }
  end

  def test_request_broken_encoding
    assert { '  『サルビア ③』' == Gome::Agent.new(force_encode: true).get('http://www.alphapolis.co.jp/manga/viewOpening/607000106/').at('.shere_line+ul>li:first-child span').text.strip }
  end

  def test_request_with_cookie
    ga = Gome::Agent.new(force_encode: true, allow_error_codes: %w(403))
    page = ga.get('http://www.alphapolis.co.jp/manga/viewOpening/455000131/')
    assert page.at('.title_area h2').nil?
    value = page.at('input[onclick^="eternityConfirm"]')[:onclick].match(/\((\d+)\)/)[1]
    ga.mech.cookie_jar << Mechanize::Cookie.new('confirm', page.uri.host, value: value, domain: page.uri.host, path: '/')
    assert { '過保護な幼なじみ' == ga.get('http://www.alphapolis.co.jp/manga/viewOpening/455000131/').at('.title_area h2').text }
  end
end
