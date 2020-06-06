# frozen_string_literal: true

module Toby
  class TomlTable
    attr_reader :name
    attr_accessor :key_values, :header_comments, :inline_comment

    def initialize(name, inline_comment)
      @name = name
      @header_comments = []
      @inline_comment = inline_comment
      @key_values = []
    end
  end

  class TomlKeyValue
    attr_reader :key
    attr_accessor :value, :table, :header_comments, :inline_comment

    def initialize(key, value, inline_comment)
      @key = key
      @value = value
      @header_comments = []
      @inline_comment = inline_comment
      @table = table
    end
  end

  class TOML < TomlTable
    attr_reader :tables

    def initialize(input_string)
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

    def toml_object_handler(obj)
      if obj.respond_to?(:header_comments) && !@comment_buffer.empty?
        obj.header_comments = @comment_buffer
        @comment_buffer = []
      end

      if obj.is_a? Toby::TomlTable
        @tables << obj

      elsif obj.is_a? Toby::TomlKeyValue
        @tables.last.key_values << obj

      end
    end

    def header_comments
      nil
    end

    def inline_comment
      nil
    end
  end
end
