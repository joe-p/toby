class Toby::TOML < Toby::TomlTable
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

    def to_hash(options = {})
        if options[:dotted_keys]
            to_dotted_keys_hash
        else
            to_split_keys_hash
        end
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
      to_hash.to_json
    end

    def inline_comment
      nil
    end

    private

    def to_dotted_keys_hash
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
  
      def to_split_keys_hash
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
                  last_hash.last[key] << tbl.to_hash
                else
                  last_hash[key] ||= []
                  last_hash[key] << tbl.to_hash
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
                  last_hash[key] = tbl.to_hash
                end
              end
  
            end
          end
        end
  
        output_hash
      end
  
  end