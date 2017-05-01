require './emoji_symbols'
require './related_words'

def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg]}" uid="#{options[:uid]}">
    <title>#{options[:title]}</title>
    <subtitle>#{options[:subtitle]}</subtitle>
    <icon>#{options[:path]}</icon>
  </item>
  ITEM
end

def match?(word, query)
  word.match(/#{query}/i)
end

def fuzzymatch?(word, query)
  word.match(/#{query.gsub(/\\ /, '').split('').join('.*')}/i)
end

images_path = File.expand_path('../images/emoji', __FILE__)

query = Regexp.escape(ARGV.first).delete(':')

related_matches = RELATED_WORDS.select { |k, v| match?(k, query) || v.any? { |r| match?(r, query) } }
related_matches_fuzzy = RELATED_WORDS.select { |k, v| fuzzymatch?(k, query) || v.any? { |r| fuzzymatch?(r, query) } }

# 1.8.7 returns a [['key', 'value']] instead of a Hash.
related_matches = related_matches.respond_to?(:keys) ? related_matches.keys : related_matches.map(&:first)
related_matches_fuzzy = related_matches_fuzzy.respond_to?(:keys) ? related_matches_fuzzy.keys : related_matches_fuzzy.map(&:first)

image_matches = Dir["#{images_path}/*.png"].map { |fn| File.basename(fn, '.png') }.select { |fn| match?(fn, query) }

matches = image_matches + related_matches + related_matches_fuzzy

items = matches.uniq.map do |elem|
  path = File.join(images_path, "#{elem}.png")
  emoji_code = "#{elem}"

  emoji = EMOJI_SYMBOLS[elem.to_sym]

  item_xml({ :arg => emoji_code, :uid => elem, :path => path, :title => emoji_code,
             :subtitle => "Copy \"#{emoji}\" (#{elem}) to clipboard" })
end.join

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
