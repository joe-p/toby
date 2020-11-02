# frozen_string_literal: false

# Represents a TOML table
# @see https://toml.io/en/v1.0.0-rc.3#table
# @see https://toml.io/en/v1.0.0-rc.3#array-of-tables
module Toby
  module TOML
    class Table
      # @return [::Array] The dotted keys of the table name.
      attr_reader :split_keys

      # @return [String] The name of table.
      attr_reader :name

      # @return [::Array<Toby::TOML::KeyValue>] The key-value pairs within the table.
      attr_accessor :key_values

      # @return [::Array<String>] The header comments above the table.
      attr_accessor :header_comments

      # @return [String] The comment in-line with the table name.
      attr_accessor :inline_comment

      # @param split_keys [::Array] Dotted keys of the table name.
      # @param inline_comment [String] The comment in-line with the key-value pair.
      # @param is_array_table [TrueClass, FalseClass] Whether the table is an array-table or not
      def initialize(split_keys, inline_comment, is_array_table)
        @split_keys = split_keys
        @name = split_keys&.join('.')
        @inline_comment = inline_comment
        @is_array_table = is_array_table

        @header_comments = []
        @key_values = []
      end

      # @return [TrueClass, FalseClass] Whether the table is an array-table or not
      def is_array_table?
        @is_array_table
      end

      # @return [Hash] TOML table represented as a hash.
      # @option options [TrueClass, FalseClass]  :dotted_keys (false) If true, dotted keys are not expanded/nested.
      # @example
      #   Given the following TOML:
      #   [some.dotted.keys]
      #   some.value = 123
      #
      #   #to_hash returns {'some' => {'dotted' => {'keys' => {'some' => {'value' => 123} } } } } }
      #   #to_hash(dotted_keys: true) returns in {'some.dotted.keys' => {'some.value'} => 123}
      def to_hash(options = {})
        if options[:dotted_keys]
          to_dotted_keys_hash(options)
        else
          to_split_keys_hash(options)
        end
      end

      # @return [String] Table in valid TOML format
      def dump
        output = StringIO.new

        dotted_keys = split_keys.map { |key| bare_key?(key) ? key : quote_key(key) }.join('.')

        output.puts "\n##{header_comments.join("\n#")}" unless header_comments.empty?

        if is_array_table?
          output.puts "[[#{dotted_keys}]]#{" ##{inline_comment}" if inline_comment}"
        else
          output.puts "[#{dotted_keys}]#{" ##{inline_comment}" if inline_comment}"
        end

        key_values.each do |kv|
          output.puts kv.dump
        end

        output.string
      end

      # @api private
      # from toml-rb
      # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
      def bare_key?(key)
        !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
      end

      # @api private
      # from toml-rb
      # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
      def quote_key(key)
        "\"#{key.gsub('"', '\\"')}\""
      end

      private

      # @api private
      def to_dotted_keys_hash(options)
        output_hash = {}

        key_values.each do |kv|
          output_hash[kv.key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash(options) : kv.value
        end

        output_hash
      end

      # @api private
      def to_split_keys_hash(options)
        output_hash = {}

        key_values.each do |kv|
          last_hash = output_hash

          kv.split_keys.each_with_index do |key, i|
            if i < (kv.split_keys.size - 1) # not the last key
              last_hash[key] ||= {}
              last_hash = last_hash[key]
            else
              last_hash[key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash(options) : kv.value
            end
          end
        end

        output_hash
      end
    end
  end
end
