#!/usr/bin/env ruby
require 'bundler/setup'
require 'hancock'

data = IO.read(File.open(File.expand_path('DocuSign API.docx', File.dirname(__FILE__))))

puts "\nThis is a bit of the data that is clearly present and not blank:"
p data[0, 100]

puts "\nThis is the data.length:"
puts data.length

puts "\nCalling data.present? will throw an `invalid byte sequence in UTF-8` error"
begin
  data.present?
rescue ArgumentError => e
  puts "\nHere is the error"
  p e.inspect
end

puts "\nIt is doing this in the String.blank? method"
puts "/\A[[:space:]]*\z/ === self"
begin
  String::BLANK_RE === data
rescue ArgumentError => e
  puts "\nHere is the String::BLANK_RE check error"
  p e.inspect
end

puts "\nSpecifically when the string contains `xFF`"
begin
  String::BLANK_RE === "\xFF"
rescue ArgumentError => e
  puts "\nHere is the `xFF` error"
  p e.inspect
end

puts "\nThe suggested fix is to check that the data is not nil and has a length > 0"
value = !data.nil? && data.length > 0
p value

puts "\nInitially I thought to check that the encoding is valid
  but see that valid_encoding? returns false
  all the way down
  even though the encoding looks valid"
p data.encoding
puts "\n"
p data.valid_encoding?
p data.force_encoding("UTF-8").valid_encoding?

p "\xFF".valid_encoding?
p "\xFF".force_encoding("UTF-8").valid_encoding?
p "\xFF".force_encoding("UTF-16").valid_encoding?
p "\xFF".force_encoding("UTF-32").valid_encoding?
