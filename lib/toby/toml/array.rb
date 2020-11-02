# frozen_string_literal: false

module Toby
  module TOML
    # Represents an array value
    # @see https://toml.io/en/v1.0.0-rc.3#array
    class Array < ::Array
      # @return [String] Array in valid TOML format
      def dump
        output = StringIO.new

        output.print '[ '

        dumped_array = map do |val|
          val.respond_to?(:dump) ? val.dump : val
        end

        output.print dumped_array.join(', ')
        output.print ' ]'

        output.string
      end

      # @param options [Hash] The options hash for the object's #to_hash method when applicable (see Toby::TOML::TOMLFile#to_hash)
      # @return [Array] Returns the value of #value, the value of #to_hash, or the object itself for every object in the Toby::TOML::Array
      def to_hash(options = {})
        h = map do |obj|
          if obj.respond_to?(:value)
            obj.value
          elsif obj.respond_to?(:to_hash)
            obj.to_hash(options)
          else
            obj
          end
        end
      end
    end
  end
end
