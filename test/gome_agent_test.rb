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
end
