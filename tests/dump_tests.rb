#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../lib/toby.rb'

class DumpTests < Minitest::Test
    def dump_test(file_name)
        expected_output = File.read("./examples/expected_outputs/#{file_name}.toml")
        input_file = File.read("./examples/#{file_name}.toml")

        assert Toby::TOML::TOMLFile.new(input_file).dump == expected_output
    end

    def test_0_5_0_dump
        dump_test('0.5.0')
    end

    def test_example_dump
        dump_test('example')
    end

    def test_fruit_dump
        dump_test('fruit')
    end

    def test_hard_dump
        dump_test('hard')
    end

    def test_newline_in_strings_dump
        dump_test('newline_in_strings')
    end

    def test_preserve_quotes_in_string_dump
        dump_test('preserve_quotes_in_string')
    end

    def test_hard_dump
        dump_test('hard')
    end

    def test_string_slash_whitespace_newline_dump
        dump_test('string_slash_whitespace_newline')
    end

    def test_table_names_dump
        dump_test('table_names')
    end

    def test_test_dump
        dump_test('test')
    end
end