module Gome
  class Crawler
    def initialize(options = {}, &block)
      @options = {
        interval: 10
      }
      @options.merge!(options.assert_valid_keys(@options.keys))
      @agent = Agent.new(&block)
      @last_requested_at = Time.at(0)
      @before_fetch_callbacks = []
      @after_fetch_callbacks = []
    end

    %w(get post put delete).each do |method|
      define_method(method) do |*args, &block|
        fetch(method, *args, &block)
      end
    end

    def before_fetch(&block)
      @before_fetch_callbacks << block
    end

    def after_fetch(&block)
      @after_fetch_callbacks << block
    end

    def start(*args, &block)
      while Agent.uri?(args.first)
        args = instance_exec(*args, &block)
        args = [args] unless args.is_a?(Array)
      end
    end

    private

    def fetch(*args)
      time = @last_requested_at + @options[:interval] - Time.now
      sleep time if time > 0
      @before_fetch_callbacks.each { |f| instance_exec(*args, &f) }
      page = @agent.send(*args)
      @last_requested_at = Time.now
      @after_fetch_callbacks.each { |f| instance_exec(*args, &f) }
      block_given? ? yield(page) : page
    end
  end
end
