# frozen_string_literal: true

require 'citrus'
require 'delegate'
require 'stringio'
require 'json'

# Contains all of the code for the Toby gem.
module TobyIO; end

module TobyIO
  # Contains all of code for TOML objects.
  module TOML; end
end

module TobyIO
  # Contains all of the code used for parsing TOML files.
  # @api private
  module Parser; end
end

require_relative 'toby_io/toml/array'
require_relative 'toby_io/toml/inline_table'
require_relative 'toby_io/toml/key_value'
require_relative 'toby_io/toml/table'
require_relative 'toby_io/toml/toml_file'

require_relative 'toby_io/parser/string'
require_relative 'toby_io/parser/datetime'
require_relative 'toby_io/parser/match_modules'
require_relative 'toby_io/parser/numbers'

# The root directory of Toby
ROOT = File.dirname(File.expand_path(__FILE__))
Citrus.load "#{ROOT}/toby_io/grammars/helper.citrus"
Citrus.load "#{ROOT}/toby_io/grammars/primitive.citrus"
Citrus.load "#{ROOT}/toby_io/grammars/document.citrus"
