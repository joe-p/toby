# frozen_string_literal: true

module Toby
  module Match
    module Array
      def value
        capture(:array_elements).value
      end
    end

    module KeyValue
      def toml_object
        Toby::TomlKeyValue.new(
          capture(:stripped_key).value.first,
          capture(:v).value,
          capture(:comment)&.stripped_comment
        )
      end
    end

    module Table
      def toml_object
        Toby::TomlTable.new(
          capture(:stripped_key).value.join('.'),
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
