# frozen_string_literal: true

module Toby
  module Dumper
    def self.dump_key_value(key_value)
      output = StringIO.new

      output.puts(header_comments(key_value))

      output.puts "#{key_value.key} = #{key_value.value}#{" ##{key_value.inline_comment}" if key_value.inline_comment}"

      output.string
    end

    def self.header_comments(obj)
      "\n#" + obj.header_comments.join("\n#") unless obj.header_comments.empty?
    end

    def self.dump_table(table)
      output = StringIO.new

      output.puts(header_comments(table))

      if table.is_array_table?
        output.puts "[[#{table.name}]]#{" ##{table.inline_comment}" if table.inline_comment}"
      else
        output.puts "[#{table.name}]#{" ##{table.inline_comment}" if table.inline_comment}"
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
