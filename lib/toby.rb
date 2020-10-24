# frozen_string_literal: true

require 'citrus'
require 'delegate'
require 'stringio'
require 'json'

# Module containing all of the code for the Toby gem.
module Toby; end

# Module containing all of code for TOML objects
module Toby::TOML; end

require_relative 'toby/toml/array'
require_relative 'toby/toml/inline_table'
require_relative 'toby/toml/key_value'
require_relative 'toby/toml/table'
require_relative 'toby/toml/toml'

require_relative 'toby/string'
require_relative 'toby/datetime'
require_relative 'toby/match_modules'
require_relative 'toby/numbers'

ROOT = File.dirname(File.expand_path(__FILE__))
Citrus.load "#{ROOT}/toby/grammars/helper.citrus"
Citrus.load "#{ROOT}/toby/grammars/primitive.citrus"
Citrus.load "#{ROOT}/toby/grammars/document.citrus"