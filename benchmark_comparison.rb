#!/usr/bin/env ruby

require 'benchmark'
begin
  require 'memory_profiler'
  MEMORY_PROFILER_AVAILABLE = true
rescue LoadError
  MEMORY_PROFILER_AVAILABLE = false
  puts "Note: memory_profiler not available on Ruby #{RUBY_VERSION}"
end
require_relative 'lib/textstat'

# Test text sample
test_text = %(
  Playing games has always been thought to be important to
  the development of well-balanced and creative children
  however, what part, if any, they should play in the lives
  of adults has never been researched that deeply. I believe
  that playing games is every bit as important for adults
  as for children. Not only is taking time out to play games
  with our children and other adults valuable to building
  interpersonal relationships but is also a wonderful way
  to release built up tension.
)

puts '=== Performance Benchmark - With Dictionary Caching ==='
puts "Ruby version: #{RUBY_VERSION}"
puts "Test text length: #{test_text.length} characters"
puts

# Clear cache before testing
TextStat.clear_dictionary_cache

# Test current performance
puts 'Testing performance with caching...'
Benchmark.bm(35) do |x|
  x.report('difficult_words (50x)') do
    50.times { TextStat.difficult_words(test_text) }
  end

  x.report('flesch_reading_ease (50x)') do
    50.times { TextStat.flesch_reading_ease(test_text) }
  end

  x.report('text_standard (50x)') do
    50.times { TextStat.text_standard(test_text) }
  end
end

if MEMORY_PROFILER_AVAILABLE
  puts "\n=== Memory Usage Analysis (With Caching) ==="
  TextStat.clear_dictionary_cache
  report = MemoryProfiler.report do
    20.times do
      TextStat.difficult_words(test_text)
      TextStat.flesch_reading_ease(test_text)
      TextStat.text_standard(test_text)
    end
  end

  puts "Total allocated memory: #{report.total_allocated_memsize} bytes"
  puts "Total retained memory: #{report.total_retained_memsize} bytes"
  puts "Total allocations: #{report.total_allocated}"
  puts "Total retentions: #{report.total_retained}"
else
  puts "\n=== Memory Usage Analysis (Skipped - memory_profiler not available) ==="
end

puts "\n=== Dictionary Cache Info ==="
cached_langs = TextStat::DictionaryManager.cached_languages
puts "Cached dictionaries: #{cached_langs.join(', ')}"
puts "Cache size: #{TextStat::DictionaryManager.cache_size} dictionaries"

# Test multiple languages
puts "\n=== Multi-language Performance ==="
languages = %w[en_us en_uk es fr de]
TextStat.clear_dictionary_cache

Benchmark.bm(35) do |x|
  x.report('Multi-language (5x each)') do
    5.times do
      languages.each do |lang|
        TextStat.difficult_words(test_text, lang)
      end
    end
  end
end

puts "\nCached dictionaries after multi-language test: #{TextStat::DictionaryManager.cached_languages.join(', ')}"
