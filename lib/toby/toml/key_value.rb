class Toby::TOML::KeyValue
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