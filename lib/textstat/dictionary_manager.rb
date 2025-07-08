require 'set'

module TextStat
  # Dictionary management with high-performance caching
  #
  # This module handles loading and caching of language-specific dictionaries
  # used for identifying difficult words. The caching system provides a 36x
  # performance improvement over reading dictionaries from disk on every call.
  #
  # @author Jakub Polak
  # @since 1.0.0
  # @example Performance optimization
  #   # First call loads dictionary from disk
  #   TextStat.difficult_words(text, 'en_us')  # ~0.047s
  #
  #   # Subsequent calls use cached dictionary
  #   TextStat.difficult_words(text, 'en_us')  # ~0.0013s (36x faster!)
  #
  #   # Check cache status
  #   TextStat::DictionaryManager.cache_size        # => 1
  #   TextStat::DictionaryManager.cached_languages  # => ['en_us']
  #
  # @example Multi-language support
  #   TextStat.difficult_words(english_text, 'en_us')
  #   TextStat.difficult_words(spanish_text, 'es')
  #   TextStat.difficult_words(french_text, 'fr')
  #   TextStat::DictionaryManager.cache_size  # => 3
  module DictionaryManager
    # Cache for loaded dictionaries
    @dictionary_cache = {}
    @dictionary_path = nil

    class << self
      attr_accessor :dictionary_cache

      # Set dictionary path
      #
      # @param path [String] path to dictionary directory
      # @return [String] the set path
      def dictionary_path=(path)
        @dictionary_path = path
      end

      # Load dictionary with automatic caching
      #
      # Loads a language-specific dictionary from disk and caches it in memory
      # for subsequent calls. This provides significant performance improvements
      # for repeated operations.
      #
      # @param language [String] language code (e.g., 'en_us', 'es', 'fr')
      # @return [Set] set of easy words for the specified language
      # @example
      #   dict = TextStat::DictionaryManager.load_dictionary('en_us')
      #   dict.include?('hello')  # => true
      #   dict.include?('comprehensive')  # => false
      # @see #supported_languages
      def load_dictionary(language)
        # Return cached dictionary if available
        return @dictionary_cache[language] if @dictionary_cache[language]

        # Load dictionary from file
        dictionary_file = File.join(dictionary_path, "#{language}.txt")
        easy_words = Set.new

        if File.exist?(dictionary_file)
          File.read(dictionary_file).each_line do |line|
            easy_words << line.chomp
          end
        end

        # Cache the loaded dictionary
        @dictionary_cache[language] = easy_words
        easy_words
      end

      # Clear all cached dictionaries
      #
      # Removes all dictionaries from memory cache. Useful for memory management
      # in long-running applications or when switching between different sets
      # of languages.
      #
      # @return [Hash] empty cache hash
      # @example
      #   TextStat::DictionaryManager.cache_size  # => 3
      #   TextStat::DictionaryManager.clear_cache
      #   TextStat::DictionaryManager.cache_size  # => 0
      def clear_cache
        @dictionary_cache.clear
      end

      # Get list of cached languages
      #
      # @return [Array<String>] array of language codes currently in cache
      # @example
      #   TextStat::DictionaryManager.cached_languages  # => ['en_us', 'es', 'fr']
      def cached_languages
        @dictionary_cache.keys
      end

      # Get number of cached dictionaries
      #
      # @return [Integer] number of dictionaries currently in cache
      # @example
      #   TextStat::DictionaryManager.cache_size  # => 3
      def cache_size
        @dictionary_cache.size
      end

      # Get path to dictionary files
      #
      # @return [String] absolute path to dictionary directory
      # @example
      #   TextStat::DictionaryManager.dictionary_path
      #   # => \"/path/to/gem/lib/dictionaries\"
      def dictionary_path
        @dictionary_path ||= File.join(TextStat::GEM_PATH, 'lib', 'dictionaries')
      end
    end

    # Count difficult words in text
    #
    # Identifies words that are considered difficult based on:
    # 1. Not being in the language's easy words dictionary
    # 2. Having more than one syllable
    #
    # This method uses the cached dictionary system for optimal performance.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for dictionary selection
    # @param return_words [Boolean] whether to return words array or count
    # @return [Integer, Set] number of difficult words or set of difficult words
    # @example Count difficult words
    #   TextStat.difficult_words(\"This is a comprehensive analysis\")  # => 2
    #
    # @example Get list of difficult words
    #   words = TextStat.difficult_words(\"comprehensive analysis\", 'en_us', true)
    #   words.to_a  # => [\"comprehensive\", \"analysis\"]
    #
    # @example Multi-language support
    #   TextStat.difficult_words(spanish_text, 'es')  # Spanish dictionary
    #   TextStat.difficult_words(french_text, 'fr')   # French dictionary
    def difficult_words(text, language = 'en_us', return_words = false)
      easy_words = DictionaryManager.load_dictionary(language)

      text_list = text.downcase.gsub(/[^0-9a-z ]/i, '').split
      diff_words_set = Set.new
      text_list.each do |value|
        next if easy_words.include? value

        diff_words_set.add(value) if syllable_count(value, language) > 1
      end

      return_words ? diff_words_set : diff_words_set.length
    end
  end
end
