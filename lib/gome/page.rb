module Gome
  module Searchable
    def one(selector, *args, &block)
      extract(at(selector), *args, &block)
    end

    def many(selector, *args, &block)
      search(selector).map { |node| extract(node, *args, &block) }
    end

    private

    def extract(node, name = nil, &block)
      return nil unless node
      node.extend(Searchable)
      if block
        node.instance_exec(node, &block)
      else
        name ? node[name] : node.text
      end
    end
  end

  class Page
    class << self
      def extractor
        new(@rules || []).extractor
      end

      def rule(rule)
        (@rules ||= []) << rule
      end

      def one(*args, &block)
        proc { one(*args, &block) }
      end

      def many(*args, &block)
        proc { many(*args, &block) }
      end
    end

    def initialize(rules)
      @rules = rules
    end

    def extract(page)
      page.extend(Searchable)
      err = nil
      @rules.each do |rule|
        begin
          return {}.tap do |h|
            rule.each do |k, v|
              h[k] = page.instance_exec(page, &v)
            end
          end
        rescue => e
          err = e
        end
      end
      raise err
    end

    def extractor
      proc { |page| extract(page) }
    end
  end
end
