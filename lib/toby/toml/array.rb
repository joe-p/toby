# Represents an array value
# @see https://toml.io/en/v1.0.0-rc.3#array
class Toby::TOML::Array < ::Array
    # @return [String] Array in valid TOML format
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

    # @return [Array] Returns the value of #value, the value of #to_hash, or the object itself for every object in the Toby::TOML::Array
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