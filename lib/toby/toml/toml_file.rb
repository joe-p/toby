# frozen_string_literal: false

# Represents an entire TOML file
# @see https://toml.io/en/v1.0.0-rc.3
class Toby::TOML::TOMLFile < Toby::TOML::Table
  # @return [Array<Toby::TOML::Table>] The tables in the TOML file
  attr_reader :tables

  # @param input_string [String] The TOML file to parse.
  def initialize(input_string)
    super(nil, '', false)

    @tables = [self]
    matches = Toby::Document.parse(input_string).matches

    @comment_buffer = []

    matches.each do |m|
      if m.respond_to? :toml_object
        toml_object_handler(m.toml_object)

      elsif m.respond_to? :stripped_comment
        @comment_buffer << m.stripped_comment

      end
    end
  end

  # @return [Hash] TOML table represented as a hash.
  # @option options [TrueClass, FalseClass]  :dotted_keys (false) If true, dotted keys are not expanded/nested.
  # @example
  #   Given the following TOML:
  #   [some.dotted.keys]
  #   some.value = 123
  #
  #   #to_hash returns {'some' => {'dotted' => {'keys' => {'some' => {'value' => 123} } } } } }
  #   #to_hash(dotted_keys: true) returns {'some.dotted.keys' => {'some.value'} => 123}
  def to_hash(options = {})
    if options[:dotted_keys]
      to_dotted_keys_hash(options)
    else
      to_split_keys_hash(options)
    end
  end

  # @return [String] The entire TOML file in valid TOML format.
  def dump
    output = StringIO.new

    key_values.each do |kv|
      output.puts kv.dump
    end

    tables.each do |table|
      next if table.is_a? Toby::TOML::TOMLFile

      output.puts table.dump
    end

    output.string
  end

  # @return [String] The TOML file in valid JSON in accordance with the TOML spec
  def to_json(*_args)
    to_hash.to_json
  end

  # @return [NilClass] A file can't have an inline comment, so this will always return nil
  def inline_comment
    nil
  end

  private

  # @api private
  def to_dotted_keys_hash(options)
    output_hash = {}

    tables.each do |tbl|
      if tbl.name.nil?
        output_hash = super

      elsif tbl.is_array_table?
        output_hash[tbl.name] ||= []
        output_hash[tbl.name] << tbl.to_hash(options)

      else
        output_hash[tbl.name] = tbl.to_hash(options)
      end
    end

    output_hash
  end

  # @api private
  def to_split_keys_hash(options)
    output_hash = {}

    tables.each do |tbl|
      if tbl.name.nil?
        output_hash = super

      elsif tbl.is_array_table?
        last_hash = output_hash

        tbl.split_keys.each_with_index do |key, i|
          if i < (tbl.split_keys.size - 1) # not the last key
            last_hash[key] ||= {}
            last_hash = last_hash[key]
          else
            if last_hash.is_a? ::Array
              last_hash.last[key] ||= []
              last_hash.last[key] << tbl.to_hash(options)
            else
              last_hash[key] ||= []
              last_hash[key] << tbl.to_hash(options)
            end
          end
        end

      else

        last_hash = output_hash
        last_last_hash = nil
        last_key = nil

        tbl.split_keys.each_with_index do |key, i|
          last_last_hash = last_hash
          if i < (tbl.split_keys.size - 1) # not the last key
            last_hash[key] ||= {}
            last_last_hash = last_hash
            last_hash = last_hash[key]
          else
            if last_hash.is_a? ::Array
              last_last_hash.last[key] = tbl.to_hash(options)
            else
              last_hash[key] = tbl.to_hash(options)
            end
          end
        end
      end
    end

    output_hash
  end

  # @api private
  def toml_object_handler(obj)
    if obj.respond_to?(:header_comments) && !@comment_buffer.empty?
      obj.header_comments = @comment_buffer
      @comment_buffer = []
    end

    if obj.is_a? Toby::TOML::Table
      @tables << obj

    elsif obj.is_a? Toby::TOML::KeyValue
      @tables.last.key_values << obj

    end
  end
end
