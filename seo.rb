require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

# Please set the values here
proxy_key = ''
base_host = ''
auth = ''
target_host = ''
path = ''

puts "This tool allows you to compare the same path on different domains"
puts "Please enter the path: default: #{path}"
input = gets.chomp
path = input if !input.to_s.strip.empty?
puts "Please enter the base hostname: default: #{base_host}"
input = gets.chomp
base_host = input if !input.to_s.strip.empty?
puts "Please enter the target hostname: default: #{target_host}"
input = gets.chomp
target_host = input if !input.to_s.strip.empty?

page1 = RestClient.get(base_host + path, cookies: { proxyKey: proxy_key })

doc = Nokogiri::HTML.parse(page1)

nodeset = doc.xpath('//link[@hreflang]/@href')
nodeset.map { |element| element["href"] }.compact
hreflangs1 = nodeset.to_a.map(&:to_s)

nodeset = doc.xpath('//a[@href]/@href')
nodeset.map { |element| element["href"] }.compact
outlinks1 = nodeset.to_a.map(&:to_s)

page2 = RestClient.get(target_host + path, cookies: { proxyKey: proxy_key })

doc = Nokogiri::HTML.parse(page2)

nodeset = doc.xpath('//link[@hreflang]/@href')
nodeset.map { |element| element["href"] }.compact
hreflangs2 = nodeset.to_a.map(&:to_s)

nodeset = doc.xpath('//a[@href]/@href')
nodeset.map { |element| element["href"] }.compact
outlinks2 = nodeset.to_a.map(&:to_s)

hreflangs2.map! do |hreflang|
    hreflang.sub(target_host.sub(auth, ''), base_host)
end

outlinks2.map! do |outlink|
    outlink.sub(target_host.sub(auth, ''), base_host)
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
