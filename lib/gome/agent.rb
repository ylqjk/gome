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

    attr_reader :mech

    def initialize(*args)
      @options = {
        force_encode: false,
        allow_error_codes: nil
      }
      @options.merge!(args.extract_options!.assert_valid_keys(@options.keys))
      @options[:allow_error_codes] = Array.try_convert(@options[:allow_error_codes]) || []
      @mech = Mechanize.new(*args)
      mech.user_agent_alias = 'Windows Edge'
      mech.max_history = 1
      yield mech if block_given?
    end

    def reload
      fail Error, 'Not requested yet' unless @last_request_args
      fetch(*@last_request_args)
    end

    %w(get post put delete).each do |method|
      define_method(method) do |uri, *args|
        fetch(uri, method, *args)
      end
    end

    private

    def fetch(*args)
      @last_request_args = args
      page = begin
               fetch_page(*args)
             rescue Mechanize::ResponseCodeError => e
               raise e unless @options[:allow_error_codes].include?(e.response_code)
               e.page
             end
      self.class.encode_page(page, @options[:force_encode])
    end

    def fetch_page(uri, method, data = nil, headers = {})
      case method.to_s.downcase
      when 'get'
        mech.get(uri.to_s, data || [], uri.to_s, headers)
      when 'post'
        mech.post(uri.to_s, data || {}, headers)
      when 'put'
        mech.put(uri.to_s, data || '', headers)
      when 'delete'
        mech.delete(uri.to_s, data || {}, headers)
      else
        fail ArgumentError, "#{method.inspect} is not support method"
      end
    end

    class Error < StandardError
    end
  end
end
