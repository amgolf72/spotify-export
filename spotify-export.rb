#!/usr/bin/env ruby

require 'net/http'
require 'htmlentities'

filename = ARGV.first
abort("Usage: spotify-export.rb <filename>") if filename == nil
abort("That file does not exist") if !File.exist?(filename)

export_targets = File.readlines(filename, sep=" ").reject{ |uri| !uri.include?("http") }

html = HTMLEntities.new
export_targets.each_with_index do |uri, count|

  current_target = URI(uri.strip)
  result = Net::HTTP.get(current_target).force_encoding("UTF-8")

  parsed_title_tag  = result.scan(/<title>(.*?) by (.*?) on Spotify<\/title>/).flatten
  parsed_album_link = result.scan(/<a href=".*?\/album\/.*?">(.*?)<\/a>/).flatten

  track_number = count + 1
  track_name   = html.decode parsed_title_tag[0]
  artist       = html.decode parsed_title_tag[1]
  album        = html.decode parsed_album_link[0]

  puts "#{track_number}. #{track_name} -- #{artist} -- #{album}"
end
