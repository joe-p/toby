class Toby::TomlArray < Array
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