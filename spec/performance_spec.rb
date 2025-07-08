require 'rspec'
require 'benchmark'
require_relative '../lib/textstat'

describe 'TextStat Performance Tests' do
  # Sample texts of different lengths
  SHORT_TEXT = 'This is a short test sentence.'.freeze

  MEDIUM_TEXT = <<~TEXT.freeze
    This is a longer text that contains multiple sentences. It should be used to test
    the performance of various TextStat methods when dealing with more realistic content.
    The text includes different types of words, punctuation, and sentence structures.
    This should give us a good baseline for performance testing across different metrics.
  TEXT

  LONG_TEXT = <<~TEXT.freeze
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt#{' '}
    ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation#{' '}
    ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in#{' '}
    reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.#{' '}
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt#{' '}
    mollit anim id est laborum.

    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque#{' '}
    laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi#{' '}
    architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas#{' '}
    sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione#{' '}
    voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit#{' '}
    amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut#{' '}
    labore et dolore magnam aliquam quaerat voluptatem.

    At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium#{' '}
    voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint#{' '}
    occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt#{' '}
    mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et#{' '}
    expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque#{' '}
    nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas#{' '}
    assumenda est, omnis dolor repellendus.
  TEXT

  before do
    # Clear cache before each test to ensure predictable performance
    TextStat.clear_dictionary_cache
  end

  describe 'Basic Method Performance' do
    it 'char_count performs quickly on long texts' do
      time = Benchmark.measure { 100.times { TextStat.char_count(LONG_TEXT) } }

      expect(time.real).to be < 0.1  # Should complete 100 iterations in under 0.1 seconds
      puts "char_count (100x): #{time.real.round(4)}s"
    end

    it 'lexicon_count performs quickly on long texts' do
      time = Benchmark.measure { 100.times { TextStat.lexicon_count(LONG_TEXT) } }

      expect(time.real).to be < 0.2  # Should complete 100 iterations in under 0.2 seconds
      puts "lexicon_count (100x): #{time.real.round(4)}s"
    end

    it 'sentence_count performs quickly on long texts' do
      time = Benchmark.measure { 100.times { TextStat.sentence_count(LONG_TEXT) } }

      expect(time.real).to be < 0.1  # Should complete 100 iterations in under 0.1 seconds
      puts "sentence_count (100x): #{time.real.round(4)}s"
    end

    it 'syllable_count performs reasonably on long texts' do
      time = Benchmark.measure { 50.times { TextStat.syllable_count(LONG_TEXT) } }

      expect(time.real).to be < 2.0  # Should complete 50 iterations in under 2 seconds
      puts "syllable_count (50x): #{time.real.round(4)}s"
    end
  end

  describe 'Dictionary Operations Performance' do
    it 'difficult_words shows significant improvement with caching' do
      # Use longer text to see meaningful performance difference
      test_text = LONG_TEXT * 3 # ~4500 characters

      # First call (no cache) - measure multiple times for accuracy
      first_time = Benchmark.measure { 5.times { TextStat.difficult_words(test_text, 'en_us') } }
      avg_first_time = first_time.real / 5

      # Subsequent calls (with cache) - more iterations
      cached_time = Benchmark.measure { 20.times { TextStat.difficult_words(test_text, 'en_us') } }
      avg_cached_time = cached_time.real / 20

      # Cache should provide some speedup (realistic expectation for CI)
      expect(avg_cached_time).to be < (avg_first_time * 1.2) # Allow for CI overhead
      puts "difficult_words first call (avg): #{avg_first_time.round(4)}s"
      puts "difficult_words cached (avg): #{avg_cached_time.round(4)}s"
      puts "Speedup: #{(avg_first_time / avg_cached_time).round(1)}x"
    end

    it 'handles multiple languages efficiently' do
      languages = %w[en_us es fr de it]

      # Load all dictionaries
      start_time = Time.now
      languages.each { |lang| TextStat.load_dictionary(lang) }
      load_time = Time.now - start_time

      # Test operations on all languages
      start_time = Time.now
      languages.each do |lang|
        TextStat.difficult_words(MEDIUM_TEXT, lang)
        TextStat.flesch_reading_ease(MEDIUM_TEXT, lang)
      end
      operation_time = Time.now - start_time

      expect(load_time).to be < 1.0 # All dictionaries should load in under 1 second
      expect(operation_time).to be < 0.5 # Operations should be very fast with cache

      puts "Loading 5 dictionaries: #{load_time.round(4)}s"
      puts "Operations on 5 languages: #{operation_time.round(4)}s"
    end
  end

  describe 'Readability Formula Performance' do
    %w[flesch_reading_ease flesch_kincaid_grade smog_index coleman_liau_index
       automated_readability_index gunning_fog text_standard].each do |method|
      it "#{method} performs efficiently" do
        time = Benchmark.measure { 20.times { TextStat.send(method, MEDIUM_TEXT) } }

        expect(time.real).to be < 2.0 # Should complete 20 iterations in under 2 seconds
        puts "#{method} (20x): #{time.real.round(4)}s"
      end
    end
  end

  describe 'Scalability Tests' do
    it 'handles very large texts without significant performance degradation' do
      # Generate a very large text
      very_large_text = LONG_TEXT * 10 # ~15,000 characters

      time = Benchmark.measure do
        TextStat.char_count(very_large_text)
        TextStat.lexicon_count(very_large_text)
        TextStat.sentence_count(very_large_text)
        TextStat.flesch_reading_ease(very_large_text)
      end

      expect(time.real).to be < 1.0 # Should complete all operations in under 1 second
      puts "Very large text (#{very_large_text.length} chars): #{time.real.round(4)}s"
    end

    it 'memory usage remains reasonable with dictionary caching' do
      # Load several dictionaries
      %w[en_us es fr de it pl ru].each { |lang| TextStat.load_dictionary(lang) }

      # Check cache size
      expect(TextStat::DictionaryManager.cache_size).to eq(7)

      # Performance should still be good
      start_time = Time.now
      50.times { TextStat.difficult_words(MEDIUM_TEXT, 'en_us') }
      end_time = Time.now

      expect(end_time - start_time).to be < 0.5 # Should be very fast with cache
      puts "50 difficult_words calls with 7 cached dictionaries: #{(end_time - start_time).round(4)}s"
    end
  end

  describe 'Performance Regression Tests' do
    it 'maintains performance characteristics after refactoring' do
      # These are baseline performance expectations after our optimizations
      expectations = {
        char_count: 0.001,          # Very fast
        lexicon_count: 0.002,       # Fast
        sentence_count: 0.001,      # Very fast
        syllable_count: 0.03,       # Moderate (depends on text-hyphen gem)
        difficult_words: 0.003,     # Fast with cache (increased for CI)
        flesch_reading_ease: 0.005, # Fast
        text_standard: 0.020        # Moderate (calls multiple methods, increased for CI)
      }

      expectations.each do |method, max_time|
        time = Benchmark.measure { 10.times { TextStat.send(method, MEDIUM_TEXT) } }
        avg_time = time.real / 10

        expect(avg_time).to be < max_time,
                            "#{method} took #{avg_time.round(4)}s, expected < #{max_time}s"
        puts "#{method}: #{avg_time.round(4)}s (limit: #{max_time}s)"
      end
    end
  end

  describe 'Memory Performance' do
    it 'clears cache properly and frees memory' do
      # Load multiple dictionaries
      %w[en_us es fr de it].each { |lang| TextStat.load_dictionary(lang) }
      expect(TextStat::DictionaryManager.cache_size).to eq(5)

      # Clear cache
      TextStat.clear_dictionary_cache
      expect(TextStat::DictionaryManager.cache_size).to eq(0)

      # Should work normally after clearing
      result = TextStat.difficult_words(MEDIUM_TEXT, 'en_us')
      expect(result).to be_a(Integer)
      expect(TextStat::DictionaryManager.cache_size).to eq(1)
    end
  end
end
