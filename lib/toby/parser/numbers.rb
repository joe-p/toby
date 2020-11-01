# frozen_string_literal: true

module Toby::Parser
  class Hexadecimal < DelegateClass(Integer)
    def to_s
      hex = to_i.to_s(16)
      "0x#{hex}"
    end

    def inspect
      to_s
    end
  end

  class Binary < DelegateClass(Integer)
    def to_s
      binary = to_i.to_s(2)
      "0b#{binary}"
    end

    def inspect
      to_s
    end
  end

  class Octal < DelegateClass(Integer)
    def to_s
      octal = to_i.to_s(8)
      "0b#{octal}"
    end

    def inspect
      to_s
    end
  end

  module Match
    module Hexadecimal
      def value
        Toby::Parser::Hexadecimal.new(to_str.to_i(16))
      end
    end

    module Binary
      def value
        Toby::Parser::Binary.new(to_str.to_i(2))
      end
    end

    module Octal
      def value
        Toby::Parser::Octal.new(to_str.to_i(8))
      end
    end
  end
end
