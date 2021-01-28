# frozen_string_literal: false

module Toby
  module TOML
    # Represents a TOML key-value pair
    # @see https://toml.io/en/v1.0.0-rc.3#keyvalue-pair
    class KeyValue
      # @return [String] The key of the key-value pair.
      attr_reader :key

      # @return [::Array] The dotted keys of the key-value pair.
      attr_reader :split_keys

      # @return [String, Integer, Float, Time, Toby::TOML::Array, Toby::TOML::InlineTable] The value of the
      #   key-value pair.
      attr_accessor :value

      # @return [Toby::TOML::Table] The table the key-value pair belongs to.
      attr_accessor :table

      # @return [::Array<String>] The header comments above the key-value pair.
      attr_accessor :header_comments

      # @return [String] The comment in-line with the key-value pair
      attr_accessor :inline_comment

      # @param split_keys [::Array] Dotted keys of the key-value pair.
      # @param value [String, Integer, Float, Time, Toby::TOML::Array, Toby::TOML::InlineTable] The value of the
      #   key-value pair.
      # @param inline_comment [String] The comment in-line with the key-value pair.
      def initialize(split_keys, value, inline_comment)
        @split_keys = split_keys
        @key = split_keys.join('.')

        @value = value
        @header_comments = []
        @inline_comment = inline_comment
        @table = table
      end

      # @return [String] The key-value pair in valid TOML
      def dump
        output = StringIO.new

        dumped_value = value.respond_to?(:dump) ? value.dump : value

        dotted_keys = split_keys.map { |key| bare_key?(key) ? key : quote_key(key) }.join('.')

        output.puts "\n##{header_comments.join("\n#")}" unless header_comments.empty?

        output.puts "#{dotted_keys} = #{dumped_value}#{" ##{inline_comment}" if inline_comment}"

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
    end
  end
end
