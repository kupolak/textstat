require 'text-hyphen'
require_relative 'basic_stats'
require_relative 'dictionary_manager'
require_relative 'readability_formulas'

module TextStat
  # Path to the TextStat gem installation directory
  #
  # This constant is used internally to locate dictionary files and other
  # gem resources. It points to the root directory of the installed gem.
  #
  # @return [String] absolute path to gem root directory
  # @example
  #   TextStat::GEM_PATH  # => \"/path/to/gems/textstat-1.0.0\"
  GEM_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))

  # Main class providing text readability analysis
  #
  # This class combines all TextStat modules to provide a unified interface
  # for text analysis. It includes basic statistics, dictionary management,
  # and readability formulas in a single class.
  #
  # The class maintains backward compatibility through method delegation,
  # ensuring that existing code continues to work seamlessly.
  #
  # @author Jakub Polak
  # @since 1.0.0
  # @example Creating an instance
  #   analyzer = TextStat::Main.new
  #   analyzer.flesch_reading_ease(\"Sample text\")  # => 83.32
  #
  # @example Using class methods (backward compatibility)
  #   TextStat::Main.flesch_reading_ease(\"Sample text\")  # => 83.32
  #   TextStat.flesch_reading_ease(\"Sample text\")        # => 83.32
  class Main
    include BasicStats
    include DictionaryManager
    include ReadabilityFormulas

    # Legacy class methods for backward compatibility
    class << self
      # Handle method delegation for backward compatibility
      #
      # This method ensures that all instance methods can be called as class methods,
      # maintaining compatibility with the pre-1.0 API.
      #
      # @param method_name [Symbol] the method name being called
      # @param args [Array] method arguments
      # @param kwargs [Hash] keyword arguments
      # @param block [Proc] block if provided
      # @return [Object] result of the method call
      # @private
      def method_missing(method_name, *args, **kwargs, &block)
        instance = new
        if instance.respond_to?(method_name)
          instance.send(method_name, *args, **kwargs, &block)
        else
          super
        end
      end

      # Check if method exists for delegation
      #
      # @param method_name [Symbol] the method name to check
      # @param include_private [Boolean] whether to include private methods
      # @return [Boolean] true if method exists
      # @private
      def respond_to_missing?(method_name, include_private = false)
        new.respond_to?(method_name, include_private) || super
      end

      # Set dictionary path for all instances
      #
      # @param path [String] path to dictionary directory
      # @return [String] the set path
      # @example
      #   TextStat::Main.dictionary_path = \"/custom/dictionaries\"
      def dictionary_path=(path)
        DictionaryManager.dictionary_path = path
      end

      # Get current dictionary path
      #
      # @return [String] current dictionary path
      # @example
      #   TextStat::Main.dictionary_path  # => \"/path/to/dictionaries\"
      def dictionary_path
        DictionaryManager.dictionary_path
      end

      # Clear all cached dictionaries
      #
      # @return [Hash] empty cache
      # @example
      #   TextStat::Main.clear_dictionary_cache
      def clear_dictionary_cache
        DictionaryManager.clear_cache
      end

      # Load dictionary for specified language
      #
      # @param language [String] language code
      # @return [Set] set of easy words for the language
      # @example
      #   TextStat::Main.load_dictionary('en_us')
      def load_dictionary(language)
        DictionaryManager.load_dictionary(language)
      end
    end
  end
end

# For backward compatibility, expose TextStat module class methods
# This ensures that TextStat.method_name works exactly like TextStat::Main.method_name
TextStat.extend(Module.new do
  # Handle method delegation at module level
  #
  # @param method_name [Symbol] the method name being called
  # @param args [Array] method arguments
  # @param kwargs [Hash] keyword arguments
  # @param block [Proc] block if provided
  # @return [Object] result of the method call
  # @private
  def method_missing(method_name, *args, **kwargs, &block)
    TextStat::Main.send(method_name, *args, **kwargs, &block)
  end

  # Check if method exists for delegation
  #
  # @param method_name [Symbol] the method name to check
  # @param include_private [Boolean] whether to include private methods
  # @return [Boolean] true if method exists
  # @private
  def respond_to_missing?(method_name, include_private = false)
    TextStat::Main.respond_to?(method_name, include_private) || super
  end
end)
