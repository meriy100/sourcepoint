#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'active_hash'
require './app/models/current_assignment.rb'


def calc_print(json)
   puts "count : #{json.count}".concat(
     " precision : ".concat( (json.map{|d|d["precision"]||0}.inject(:+)/ json.count ).to_s )
   ).concat(
     " recall : ".concat( (json.map{|d|d["recall"]||0}.inject(:+)/ json.count ).to_s )
   ).concat(
     " f : ".concat( (json.map{|d|d["f"]||0}.inject(:+)/ json.count ).to_s )
   )
rescue NoMethodError => e
  STDERR.puts e
end

if __FILE__ == $0
  (
    if ARGV.first  == '-c'
      ARGV.shift
      CurrentAssignment.where(code: ARGV).map(&:id).flat_map{|id| Dir["data/#{id}/*.json"] }
    else
      ARGV
    end
  ).each do |path|
    puts path
    calc_print(JSON[File.read(path)])
    puts
  end
end
