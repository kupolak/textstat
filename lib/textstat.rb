# TextStat - Ruby gem for text readability analysis
#
# @author Jakub Polak
# @version 1.0.0
# @since 0.1.0
#
# TextStat is a Ruby gem that calculates statistics from text to determine
# readability, complexity and grade level of a particular corpus.
#
# @example Basic usage
#   require 'textstat'
#
#   text = \"This is a sample text for analysis.\"
#   TextStat.flesch_reading_ease(text)  # => 83.32
#   TextStat.difficult_words(text)      # => 1
#   TextStat.text_standard(text)        # => \"6th and 7th grade\"
#
# @example Performance optimization with caching
#   # Dictionary caching provides 36x performance improvement
#   TextStat.difficult_words(text, 'en_us')  # First call loads dictionary
#   TextStat.difficult_words(text, 'en_us')  # Subsequent calls use cache
#
#   # Check cache status
#   TextStat::DictionaryManager.cache_size  # => 1
#   TextStat::DictionaryManager.cached_languages  # => ['en_us']
#
# @see https://github.com/kupolak/textstat
# @see CHANGELOG.md

require_relative 'textstat/main'

# For backward compatibility, this file now just loads the new modular structure
# All functionality has been moved to separate modules:
# - TextStat::BasicStats - basic text statistics
# - TextStat::DictionaryManager - dictionary management with caching
# - TextStat::ReadabilityFormulas - readability calculation formulas
