#!/usr/bin/env ruby
# frozen_string_literal: false

require 'minitest/autorun'
require_relative '../lib/toby'

# Tests the TOMLData#to_json functionality by comparing the actual output to the expected output
class JsonTests < Minitest::Test
  def json_test(file_name)
    expected_output = File.read("#{__dir__}/examples/expected_outputs/spec_json/#{file_name}.json")
    input_file = File.read("#{__dir__}/examples/spec_json/#{file_name}.toml")

    assert JSON.parse(Toby::TOML::TOMLData.new(input_file).to_json) == JSON.parse(expected_output)
  end

  def test_array_of_tables_json
    json_test('array_of_tables')
  end

  def test_dotted_keys_json
    json_test('dotted_keys')
  end

  def test_integer_keys_json
    json_test('integer_keys')
  end

  def test_nested_array_of_tables_json
    json_test('nested_array_of_tables')
  end

  def test_table_names_json
    json_test('table_names')
  end
end
