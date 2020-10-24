class Toby::TomlTable
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