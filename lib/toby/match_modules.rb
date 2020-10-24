# frozen_string_literal: true

module Toby
  module Match
    module InlineTable
      def value
        kv_array = []

        captures(:keyvalue).each do |kv|
          kv_array << Toby::TOML::KeyValue.new(kv.keys, kv.value, nil)
        end

        Toby::TOML::InlineTable.new kv_array
      end
    end

    module Array
      def value
        Toby::TOML::Array.new capture(:array_elements).value
      end
    end

    module KeyValue
      def keys
        capture(:stripped_key).value
      end

      def value
        capture(:v).value
      end

      def comment
        capture(:comment)&.stripped_comment
      end

      def toml_object
        Toby::TOML::KeyValue.new(
          keys,
          value,
          comment
        )
      end
    end

    module Table
      def toml_object
        Toby::TOML::Table.new(
          capture(:stripped_key).value,
          capture(:comment)&.stripped_comment,
          false
        )
      end
    end

    module ArrayTable
      def toml_object
        Toby::TOML::Table.new(
          capture(:stripped_key).value,
          capture(:comment)&.stripped_comment,
          true
        )
      end
    end

    module Comment
      def stripped_comment
        value.sub('#', '').strip!
      end
    end
  end
end
