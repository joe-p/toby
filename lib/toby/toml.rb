# frozen_string_literal: true

module Toby
  class TomlArray < Array
    def dump
      output = StringIO.new

      output.print '[ '

      dumped_array = self.map do |val|
        val = val.respond_to?(:dump) ? val.dump : val
      end

      output.print dumped_array.join(', ')
      output.print ' ]'

      output.string
    end

    def to_hash
      h = self.map do |obj| 
        if obj.respond_to?(:value) 
          obj.value
        elsif obj.respond_to?(:to_hash)
          obj.to_hash
        else
          obj
        end
      end
    end
  end

  class TomlInlineTable < Array
    def dump
      output = StringIO.new

      output.print '{'

      each do |kv|
        dumped_value = kv.value.respond_to?(:dump) ? kv.value.dump : kv.value

        dotted_keys = kv.split_keys.map { |key| kv.bare_key?(key) ? key : kv.quote_key(key) }.join('.')

        output.print " #{dotted_keys} = #{dumped_value},"
      end

      output.string.gsub(/,$/, ' }')
    end

    def to_hash
      output_hash = {}

      each do |kv|
        output_hash[kv.key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash : kv.value
      end

      output_hash
    end
  end

  class TomlTable
    attr_reader :split_keys, :name
    attr_accessor :key_values, :header_comments, :inline_comment

    def initialize(split_keys, inline_comment, is_array_table)
      @split_keys = split_keys
      @name = split_keys&.join('.')
      @inline_comment = inline_comment
      @is_array_table = is_array_table

      @header_comments = []
      @key_values = []
    end

    def is_array_table?
      @is_array_table
    end

    def to_hash
      output_hash = {}

      key_values.each do |kv|
        output_hash[kv.key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash : kv.value
      end

      output_hash
    end

    def to_expanded_hash
      output_hash = {}

      key_values.each do |kv|
        last_hash = output_hash

        kv.split_keys.each_with_index do |key, i|
          
          if i < (kv.split_keys.size - 1) # not the last key
            last_hash[key] ||= {}
            last_hash = last_hash[key]
          else
            last_hash[key] = kv.value.respond_to?(:to_hash) ? kv.value.to_hash : kv.value
          end
        end

      end

      output_hash
    end

    def dump
      output = StringIO.new

      dotted_keys = split_keys.map { |key| bare_key?(key) ? key : quote_key(key) }.join('.')

      output.puts "\n#" + header_comments.join("\n#") unless header_comments.empty?

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

    # from toml-rb
    # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def bare_key?(key)
      !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
    end

    # from toml-rb
    # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def quote_key(key)
      '"' + key.gsub('"', '\\"') + '"'
    end
  end

  class TomlKeyValue
    attr_reader :key, :split_keys
    attr_accessor :value, :table, :header_comments, :inline_comment

    def initialize(split_keys, value, inline_comment)
      @split_keys = split_keys
      @key = split_keys.join('.')

      @value = value
      @header_comments = []
      @inline_comment = inline_comment
      @table = table
    end

    def dump
      output = StringIO.new

      dumped_value = value.respond_to?(:dump) ? value.dump : value

      dotted_keys = split_keys.map { |key| bare_key?(key) ? key : quote_key(key) }.join('.')

      output.puts "\n#" + header_comments.join("\n#") unless header_comments.empty?

      output.puts "#{dotted_keys} = #{dumped_value}#{" ##{inline_comment}" if inline_comment}"

      output.string
    end

    # from toml-rb
    # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def bare_key?(key)
      !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
    end

    # from toml-rb
    # https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def quote_key(key)
      '"' + key.gsub('"', '\\"') + '"'
    end
  end

  class TOML < TomlTable
    attr_reader :tables

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

    def to_hash
      output_hash = {}

      tables.each do |tbl|
        if tbl.name.nil?
          output_hash = super

        elsif tbl.is_array_table?
          output_hash[tbl.name] ||= []
          output_hash[tbl.name] << tbl.to_hash

        else
          output_hash[tbl.name] = tbl.to_hash
        end
      end

      output_hash
    end

    def to_expanded_hash
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
              if last_hash.is_a? Array
                last_hash.last[key] ||= []
                last_hash.last[key] << tbl.to_expanded_hash
              else
                last_hash[key] ||= []
                last_hash[key] << tbl.to_expanded_hash
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
              if last_hash.is_a? Array
                last_last_hash.last[key] = tbl.to_hash
              else
                last_hash[key] = tbl.to_expanded_hash
              end
            end

          end
        end
      end

      output_hash
    end

    def dump
      output = StringIO.new

      key_values.each do |kv|
        output.puts kv.dump
      end

      tables.each do |table|
        next if table.is_a? Toby::TOML

        output.puts table.dump
      end

      output.string
    end

    def to_json
      to_expanded_hash.to_json
    end

    def inline_comment
      nil
    end
  end
end
