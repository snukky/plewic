#!/usr/bin/env ruby
#encoding:utf-8
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'plerrex'
require 'ostruct'
require 'optparse'
require 'awesome_print'

include Plerrex

def run!
  $options = parse_options
  ap $options if $options.verbose
  
  @formatter = Formatter.new
  errors = all_error_examples_for_category

  @formatter.print(errors, :color => true).each{ |e| puts "#{e}\n" }

  puts "Found #{errors.size} examples" if $options.verbose
end

def all_error_examples_for_category
  category = Recognizer::ERRORS[$options.category]
  error_examples = []

  files = Dir.glob($options.corpus_files).sort
  files.shuffle! if $options.random
  
  files.each do |file|
    puts "loading file #{file}..." if $options.verbose

    file_content = File.read(file)
    errors = @formatter.deformat(file_content).
                        first.
                        delete_if{ |err| err.kind_of?(Hash) }

    error_examples += if category.nil?
                        errors
                      else
                        errors.select do |err| 
                          err.errors.any?{ |e| e.category == category }
                        end
                      end
  end

  error_examples
end

def parse_options
  options = OpenStruct.new

  options.corpus_files = 'plewic.*.yaml'
  options.category = nil
  options.verbose = false
  options.random = false

  OptionParser.new do |opts|
    opts.banner = "Search in PlEWi corpus files\n" \
                  "Usage: plewic.rb 'plewic.files.*.yaml' [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("-c", "--category SYM", "Set error category") do |c|
      options.category = c.to_sym
    end

    opts.on("-l", "--list-categories", "List categories") do
      ap Plerrex::Recognizer::ERRORS
      exit
    end

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      options.verbose = v
    end

    opts.on("-r", "--[no-]random", "Get random PlEWiC file") do |r|
      options.random = r
    end
  end.parse!

  options.corpus_files = ARGV[0] unless ARGV[0].nil?

  options
end

run!
