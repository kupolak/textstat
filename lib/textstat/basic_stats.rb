module TextStat
  # Basic text statistics calculations
  #
  # This module provides fundamental text analysis methods such as counting
  # characters, words, syllables, and sentences. These statistics form the
  # foundation for more advanced readability calculations.
  #
  # @author Jakub Polak
  # @since 1.0.0
  # @example Basic usage
  #   text = "Hello world! This is a test."
  #   TextStat.char_count(text)          # => 23
  #   TextStat.lexicon_count(text)       # => 6
  #   TextStat.syllable_count(text)      # => 6
  #   TextStat.sentence_count(text)      # => 2
  module BasicStats
    # Count characters in text
    #
    # @param text [String] the text to analyze
    # @param ignore_spaces [Boolean] whether to ignore spaces in counting
    # @return [Integer] number of characters
    # @example
    #   TextStat.char_count("Hello world!")        # => 11
    #   TextStat.char_count("Hello world!", false) # => 12
    def char_count(text, ignore_spaces = true)
      text = text.delete(' ') if ignore_spaces
      text.length
    end

    # Count words (lexicons) in text
    #
    # @param text [String] the text to analyze
    # @param remove_punctuation [Boolean] whether to remove punctuation before counting
    # @return [Integer] number of words
    # @example
    #   TextStat.lexicon_count("Hello, world!")       # => 2
    #   TextStat.lexicon_count("Hello, world!", false) # => 2
    def lexicon_count(text, remove_punctuation = true)
      text = text.gsub(/[^a-zA-Z\s]/, '').squeeze(' ') if remove_punctuation
      text.split.count
    end

    # Count syllables in text using hyphenation
    #
    # Uses the text-hyphen library for accurate syllable counting across
    # different languages. Supports 22 languages including English, Spanish,
    # French, German, and more.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for hyphenation dictionary
    # @return [Integer] number of syllables
    # @example
    #   TextStat.syllable_count("beautiful")          # => 3
    #   TextStat.syllable_count("hello", "en_us")      # => 2
    #   TextStat.syllable_count("bonjour", "fr")       # => 2
    # @see TextStat::DictionaryManager.supported_languages
    def syllable_count(text, language = 'en_us')
      return 0 if text.empty?

      text = text.downcase
      text.gsub(/[^a-zA-Z\s]/, '').squeeze(' ')
      dictionary = Text::Hyphen.new(language: language, left: 0, right: 0)
      count = 0
      text.split.each do |word|
        word_hyphenated = dictionary.visualise(word)
        count += word_hyphenated.count('-') + 1
      end
      count
    end

    # Count sentences in text
    #
    # Identifies sentence boundaries using punctuation marks (.!?) followed
    # by whitespace and capital letters.
    #
    # @param text [String] the text to analyze
    # @return [Integer] number of sentences
    # @example
    #   TextStat.sentence_count("Hello world! How are you?")  # => 2
    #   TextStat.sentence_count("Dr. Smith went to the U.S.A.") # => 1
    def sentence_count(text)
      text.scan(/[\.\?!][\'\\)\]]*[ |\n][A-Z]/).map(&:strip).count + 1
    end

    # Calculate average sentence length
    #
    # @param text [String] the text to analyze
    # @return [Float] average number of words per sentence
    # @example
    #   TextStat.avg_sentence_length("Hello world! How are you?")  # => 3.0
    def avg_sentence_length(text)
      asl = lexicon_count(text).to_f / sentence_count(text)
      asl.round(1)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate average syllables per word
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for hyphenation dictionary
    # @return [Float] average number of syllables per word
    # @example
    #   TextStat.avg_syllables_per_word("beautiful morning")  # => 2.5
    def avg_syllables_per_word(text, language = 'en_us')
      syllable = syllable_count(text, language)
      words = lexicon_count(text)
      syllables_per_word = syllable.to_f / words
      syllables_per_word.round(1)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate average letters per word
    #
    # @param text [String] the text to analyze
    # @return [Float] average number of letters per word
    # @example
    #   TextStat.avg_letter_per_word("hello world")  # => 5.0
    def avg_letter_per_word(text)
      letters_per_word = char_count(text).to_f / lexicon_count(text)
      letters_per_word.round(2)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate average sentences per word
    #
    # @param text [String] the text to analyze
    # @return [Float] average number of sentences per word
    # @example
    #   TextStat.avg_sentence_per_word("Hello world! How are you?")  # => 0.4
    def avg_sentence_per_word(text)
      sentence_per_word = sentence_count(text).to_f / lexicon_count(text)
      sentence_per_word.round(2)
    rescue ZeroDivisionError
      0.0
    end

    # Count polysyllabic words (3+ syllables)
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for hyphenation dictionary
    # @return [Integer] number of polysyllabic words
    # @example
    #   TextStat.polysyllab_count("beautiful complicated")  # => 2
    def polysyllab_count(text, language = 'en_us')
      count = 0
      text.split.each do |word|
        w = syllable_count(word, language)
        count += 1 if w >= 3
      end
      count
    end
  end
end
