# frozen_string_literal: true

module Toby
  module Dumper
    # from toml-rb: https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def self.bare_key?(key)
      !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
    end

    # from toml-rb: https://github.com/emancu/toml-rb/blob/ca5bf9563f1ef2c467bd43eec1d035e83b61ac88/lib/toml-rb/dumper.rb
    def self.quote_key(key)
      '"' + key.gsub('"', '\\"') + '"'
    end

    def self.dump_key_value(key_value)
      output = StringIO.new

      value = key_value.value
      value = value.dump if value.is_a? String

      key = key_value.key
      key = quote_key(key) unless bare_key? key


      output.puts(header_comments(key_value))



      output.puts "#{key} = #{value}#{" ##{key_value.inline_comment}" if key_value.inline_comment}"

      output.string
    end

    def self.string_handler(str)
      str.gsub(/\\(#[$@{])/, '\1')
    end

    def self.header_comments(obj)
      "\n#" + obj.header_comments.join("\n#") unless obj.header_comments.empty?
    end

    def self.dump_table(table)
      output = StringIO.new
    
      dotted_keys = table.split_keys.map { |key| bare_key?(key) ? key : quote_key(key) }.join('.')

      output.puts(header_comments(table))

      if table.is_array_table?
        output.puts "[[#{dotted_keys}]]#{" ##{table.inline_comment}" if table.inline_comment}"
      else
        output.puts "[#{dotted_keys}]#{" ##{table.inline_comment}" if table.inline_comment}"
      end

      table.key_values.each do |kv|
        output.puts dump_key_value kv
      end

      output.string
    end

    def self.dump_toml_object(toml_obj)
      output = StringIO.new

      toml_obj.key_values.each do |kv|
        output.puts dump_key_value(kv)
      end

      toml_obj.tables.each do |table|
        next if table.name.nil? # This is the root TOML object

        output.puts dump_table table
      end

      output.string
    end
  end
end
