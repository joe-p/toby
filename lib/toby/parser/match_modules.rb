# frozen_string_literal: true

module Toby
  module Parser
    module Match
      # @see https://toml.io/en/v1.0.0-rc.3#inline-table
      module InlineTable
        def value
          kv_array = []

          captures(:keyvalue).each do |kv|
            kv_array << Toby::TOML::KeyValue.new(kv.keys, kv.value, nil)
          end

          Toby::TOML::InlineTable.new kv_array
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#array
      module Array
        def value
          Toby::TOML::Array.new capture(:array_elements).value
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#keyvalue-pair
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

      # @see https://toml.io/en/v1.0.0-rc.3#table
      module Table
        def toml_object
          Toby::TOML::Table.new(
            capture(:stripped_key).value,
            capture(:comment)&.stripped_comment,
            false
          )
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#array-of-tables
      module ArrayTable
        def toml_object
          Toby::TOML::Table.new(
            capture(:stripped_key).value,
            capture(:comment)&.stripped_comment,
            true
          )
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#comment
      module Comment
        def stripped_comment
          value.sub('#', '').strip!
        end
      end
    end
  end
end
