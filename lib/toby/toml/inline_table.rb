# frozen_string_literal: false

module Toby
  module TOML
    # Represents an inline-table value
    # @see https://toml.io/en/v1.0.0-rc.3#inline-table
    class InlineTable < Array
      # @return [String] Inline table in valid TOML format
      def dump
        output = StringIO.new

        output.print '{'

        each do |kv|
          dumped_value = kv.value.respond_to?(:dump) ? kv.value.dump : kv.value

          dotted_keys = kv.split_keys.map { |key| kv.bare_key?(key) ? key : kv.quote_key(key) }.join('.')

          output.print " #{dotted_keys} = #{dumped_value},"
        end

        output.string.gsub(/,$/, ' }')
      end

      # @return [Hash] TOML table represented as a hash.
      # @option options [TrueClass, FalseClass]  :dotted_keys (false) If true, dotted keys are not expanded/nested.
      # @example
      #   Given the following TOML:
      #   table = {a.b.c = 123}
      #
      #   #to_hash returns { "table" => {"a" => { "b" => { "c" => 123 } } } }
      #   #to_hash(dotted_keys: true) returns {'some.dotted.keys' => {'some.value'} => 123}
      def to_hash(options = {})
        if options[:dotted_keys]
          to_dotted_keys_hash
        else
          to_split_keys_hash
        end
      end

      private

      # @api private
      def to_split_keys_hash
        output_hash = {}

        last_hash = output_hash
        last_last_hash = nil

        each do |kv|
          kv.split_keys.each_with_index do |key, i|
            last_last_hash = last_hash

            if i < (kv.split_keys.size - 1) # not the last key
              last_hash[key] ||= {}
              last_last_hash = last_hash
              last_hash = last_hash[key]
            else
              last_hash[key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash(options) : kv.value
            end
          end
        end

        output_hash
      end

      # @api private
      def to_dotted_keys_hash
        output_hash = {}

        each do |kv|
          output_hash[kv.key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash(options) : kv.value
        end

        output_hash
      end
    end
  end
end
