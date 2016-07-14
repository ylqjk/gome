require 'active_support/all'
require 'mechanize'
require 'nkf'

module Gome
  class Agent
    class << self
      def encode_page(page, encoding)
        return page unless encoding
        body = page.body
        encoding = NKF.guess(body) if encoding == true
        body.force_encoding(encoding)
        body.encode!('UTF-8')
        page.class.new(page.uri, page.response, body, page.code, page.mech)
      end
    end

    def initialize(*args)
      @options = {
        force_encode: false
      }
      @options.merge!(args.extract_options!.assert_valid_keys(@options.keys))
      @mech = Mechanize.new(*args)
      @mech.user_agent_alias = 'Windows Edge'
      @mech.max_history = 1
      yield @mech if block_given?
    end

    %w(get post put delete).each do |method|
      define_method(method) do |uri, *args|
        fetch(uri, method, *args)
      end
    end

    private

    def fetch(*args)
      self.class.encode_page(fetch_page(*args), @options[:force_encode])
    end

    def fetch_page(uri, method, data = nil, headers = {})
      case method.to_s.downcase
      when 'get'
        @mech.get(uri.to_s, data || [], uri.to_s, headers)
      when 'post'
        @mech.post(uri.to_s, data || {}, headers)
      when 'put'
        @mech.put(uri.to_s, data || '', headers)
      when 'delete'
        @mech.delete(uri.to_s, data || {}, headers)
      else
        fail ArgumentError, "#{method.inspect} is not support method"
      end
    end
  end
end
