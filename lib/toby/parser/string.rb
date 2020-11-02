# frozen_string_literal: true

module Toby
  module Parser
    # Used in primitive.citrus
    module BasicString
      SPECIAL_CHARS = {
        '\\0' => "\0",
        '\\t' => "\t",
        '\\b' => "\b",
        '\\f' => "\f",
        '\\n' => "\n",
        '\\r' => "\r",
        '\\"' => '"',
        '\\\\' => '\\'
      }.freeze

      def value
        aux = Toby::Parser::BasicString.transform_escaped_chars first.value

        aux[1...-1]
      end

      # Replace the unicode escaped characters with the corresponding character
      # e.g. \u03B4 => ?
      def self.decode_unicode(str)
        [str[2..-1].to_i(16)].pack('U')
      end

      def self.transform_escaped_chars(str)
        str.gsub(/\\(u[\da-fA-F]{4}|U[\da-fA-F]{8}|.)/) do |m|
          if m.size == 2
            SPECIAL_CHARS[m] || parse_error(m)
          else
            decode_unicode(m).force_encoding('UTF-8')
          end
        end
      end

      def self.parse_error(m)
        raise ParseError, "Escape sequence #{m} is reserved"
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#string
    module LiteralString
      def value
        first.value[1...-1]
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#string
    module MultilineString
      def value
        return '' if captures[:text].empty?

        aux = captures[:text].first.value

        # Remove spaces on multilined Singleline strings
        aux.gsub!(/\\\r?\n[\n\t\r ]*/, '')

        Toby::Parser::BasicString.transform_escaped_chars aux
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#string
    module MultilineLiteral
      def value
        return '' if captures[:text].empty?

        aux = captures[:text].first.value

        aux.gsub(/\\\r?\n[\n\t\r ]*/, '')
      end
    end
  end
end
