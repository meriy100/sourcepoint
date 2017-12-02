#!/usr/bin/env ruby

require 'json'
require 'pry'


def calc_print(json)
  puts "count : #{json.count}"
  puts "recall : ".concat( (json.map{|d|d["recall"]||0}.inject(:+)/ json.count ).to_s )
  puts "precision : ".concat( (json.map{|d|d["precision"]||0}.inject(:+)/ json.count ).to_s )
  puts "f : ".concat( (json.map{|d|d["f"]||0}.inject(:+)/ json.count ).to_s )
rescue NoMethodError => e
  STDERR.puts e
end

if __FILE__ == $0
  ARGV.each do |path|
    puts path
    calc_print(JSON[File.read(path)])
    puts
  end
end
