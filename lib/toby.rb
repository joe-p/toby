# frozen_string_literal: true

require 'citrus'
require 'delegate'
require 'stringio'
require 'json'

require_relative 'toby/toml'
require_relative 'toby/string'
require_relative 'toby/datetime'
require_relative 'toby/match_modules'
require_relative 'toby/numbers'

ROOT = File.dirname(File.expand_path(__FILE__))
Citrus.load "#{ROOT}/toby/grammars/helper.citrus"
Citrus.load "#{ROOT}/toby/grammars/primitive.citrus"
Citrus.load "#{ROOT}/toby/grammars/document.citrus"

module Toby; end
