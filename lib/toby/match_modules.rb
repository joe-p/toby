# frozen_string_literal: true

module Toby
  module Match
    module InlineTable
      def value
        kv_hash = {}

        captures(:keyvalue).each do |kv|
          kv_hash[kv.key] = kv.value
        end

        kv_hash
      end
    end

    module Array
      def value
        capture(:array_elements).value
      end
    end

    module KeyValue
      def key
        capture(:stripped_key).value.first
      end

      def value
        capture(:v).value
      end

      def comment
        capture(:comment)&.stripped_comment
      end

      def toml_object
        Toby::TomlKeyValue.new(
          key,
          value,
          comment
        )
      end
    end

    module Table
      def toml_object
        Toby::TomlTable.new(
          capture(:stripped_key).value,
          capture(:comment)&.stripped_comment,
          false
        )
      end
    end

    module ArrayTable
      def toml_object
        Toby::TomlTable.new(
          capture(:stripped_key).value.join('.'),
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
