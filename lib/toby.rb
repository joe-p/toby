# frozen_string_literal: true

require 'citrus'
require 'delegate'
require 'stringio'
require 'json'

# Contains all of the code for the Toby gem.
module Toby; end

module Toby
  # Contains all of code for TOML objects.
  module TOML; end
end

module Toby
  # Contains all of the code used for parsing TOML files.
  # @api private
  module Parser; end
end

require_relative 'toby/toml/array'
require_relative 'toby/toml/inline_table'
require_relative 'toby/toml/key_value'
require_relative 'toby/toml/table'
require_relative 'toby/toml/toml_data'

require_relative 'toby/parser/string'
require_relative 'toby/parser/datetime'
require_relative 'toby/parser/match_modules'
require_relative 'toby/parser/numbers'

# The root directory of Toby
ROOT = File.dirname(File.expand_path(__FILE__))
Citrus.load "#{ROOT}/toby/grammars/helper.citrus"
Citrus.load "#{ROOT}/toby/grammars/primitive.citrus"
Citrus.load "#{ROOT}/toby/grammars/document.citrus"
