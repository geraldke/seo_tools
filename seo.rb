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

page2 = RestClient.get(target_host + path, cookies: { proxyKey: proxy_key })

doc = Nokogiri::HTML.parse(page2)
nodeset = doc.xpath('//link[@hreflang]/@href')
nodeset.map { |element| element["href"] }.compact

hreflangs2 = nodeset.to_a.map(&:to_s)

hreflangs2.map! do |hreflang|
    hreflang.sub(target_host.sub(auth, ''), base_host)
end

additional = hreflangs2 - hreflangs1
missing = hreflangs1 - hreflangs2

puts "Additional:"
ap additional

puts "Missing:"
ap missing
