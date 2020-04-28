require 'rubygems'
require 'bundler/setup'
require './settings'

Bundler.require(:default)

puts "This tool allows you to compare the same path on different domains"
puts "Please enter the path:"
input = gets.chomp
path = input if !input.to_s.strip.empty?

base_host = Settings::BASE_HOST
target_host = Settings::TARGET_HOST.clone
target_host = target_host.insert('https://'.size, Settings::BASIC_AUTH + '@')

page1 = RestClient.get(base_host + path, cookies: { proxyKey: Settings::PROXY_KEY })

doc = Nokogiri::HTML.parse(page1)

nodeset = doc.xpath('//link[@hreflang]/@href')
nodeset.map { |element| element["href"] }.compact
hreflangs1 = nodeset.to_a.map(&:to_s)

nodeset = doc.xpath('//a[@href]/@href')
nodeset.map { |element| element["href"] }.compact
outlinks1 = nodeset.to_a.map(&:to_s)

page2 = RestClient.get(target_host + path, cookies: { proxyKey: Settings::PROXY_KEY })

doc = Nokogiri::HTML.parse(page2)

nodeset = doc.xpath('//link[@hreflang]/@href')
nodeset.map { |element| element["href"] }.compact
hreflangs2 = nodeset.to_a.map(&:to_s)

nodeset = doc.xpath('//a[@href]/@href')
nodeset.map { |element| element["href"] }.compact
outlinks2 = nodeset.to_a.map(&:to_s)

hreflangs2.map! do |hreflang|
  hreflang.sub(Settings::TARGET_HOST, Settings::BASE_HOST)
end

outlinks2.map! do |outlink|
  outlink.sub(Settings::TARGET_HOST, Settings::BASE_HOST)
end

additional_hreflangs = hreflangs2 - hreflangs1
missing_hreflangs = hreflangs1 - hreflangs2

additional_outlinks = outlinks2 - outlinks1
missing_outlinks = outlinks1 - outlinks2

puts "HREFLANGS:"

puts "Additional:"
ap additional_hreflangs

puts "Missing:"
ap missing_hreflangs

puts "OUTLINKS:"

puts "Additional:"
ap additional_outlinks

puts "Missing:"
ap missing_outlinks
