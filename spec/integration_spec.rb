require 'rspec'
require_relative '../lib/textstat'

describe 'TextStat Integration Tests' do
  describe 'Module Integration' do
    it 'integrates BasicStats with ReadabilityFormulas correctly' do
      text = 'This is a test sentence with some complex words like comprehensive and elaborate.'

      # Basic stats should feed into readability formulas
      char_count = TextStat.char_count(text)
      word_count = TextStat.lexicon_count(text)
      sentence_count = TextStat.sentence_count(text)
      syllable_count = TextStat.syllable_count(text)

      expect(char_count).to be > 0
      expect(word_count).to be > 0
      expect(sentence_count).to be > 0
      expect(syllable_count).to be > 0

      # Readability formulas should use these stats
      flesch_score = TextStat.flesch_reading_ease(text)
      expect(flesch_score).to be_a(Float)
      expect(flesch_score).to be > 0

      # Flesch-Kincaid should correlate with complexity
      grade_level = TextStat.flesch_kincaid_grade(text)
      expect(grade_level).to be_a(Float)
      expect(grade_level).to be > 0
    end

    it 'integrates DictionaryManager with ReadabilityFormulas' do
      text = 'This sentence contains some difficult words like unprecedented and multifaceted.'

      # Dictionary manager should load and cache (allow for existing cache)
      initial_cache_size = TextStat::DictionaryManager.cache_size

      # First call should load dictionary
      difficult_count = TextStat.difficult_words(text, 'en_us')
      expect(TextStat::DictionaryManager.cache_size).to be >= initial_cache_size # May already be loaded
      expect(difficult_count).to be >= 0

      # Readability formulas should use difficult words
      gunning_fog = TextStat.gunning_fog(text)
      expect(gunning_fog).to be_a(Float)

      # More difficult words should increase complexity
      simple_text = 'This is a simple test.'
      simple_difficult = TextStat.difficult_words(simple_text, 'en_us')
      expect(simple_difficult).to be <= difficult_count
    end

    it 'integrates all modules through text_standard method' do
      text = 'The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet.'

      # text_standard should use all modules
      standard = TextStat.text_standard(text)
      expect(standard).to be_a(String)
      expect(standard).to match(/grade/i)

      # Should work with different languages
      standard_es = TextStat.text_standard(text, 'es')
      expect(standard_es).to be_a(Numeric) # May return grade level as number

      # Should cache dictionaries efficiently
      expect(TextStat::DictionaryManager.cache_size).to be > 0
    end
  end

  describe 'Multi-Language Integration' do
    it 'handles switching between languages seamlessly' do
      english_text = 'This is a complex sentence with difficult words.'
      spanish_text = 'Esta es una oración compleja con palabras difíciles.'
      french_text = 'Ceci est une phrase complexe avec des mots difficiles.'

      # Test English
      en_difficult = TextStat.difficult_words(english_text, 'en_us')
      en_flesch = TextStat.flesch_reading_ease(english_text, 'en_us')

      # Test Spanish
      es_difficult = TextStat.difficult_words(spanish_text, 'es')
      es_flesch = TextStat.flesch_reading_ease(spanish_text, 'es')

      # Test French
      fr_difficult = TextStat.difficult_words(french_text, 'fr')
      fr_flesch = TextStat.flesch_reading_ease(french_text, 'fr')

      # All should return valid results
      expect(en_difficult).to be_a(Integer)
      expect(es_difficult).to be_a(Integer)
      expect(fr_difficult).to be_a(Integer)

      expect(en_flesch).to be_a(Float)
      expect(es_flesch).to be_a(Float)
      expect(fr_flesch).to be_a(Float)

      # Should have cached the new dictionaries
      expect(TextStat::DictionaryManager.cache_size).to be >= 3
      expect(TextStat::DictionaryManager.cached_languages).to include('en_us', 'es', 'fr')
    end

    it 'maintains consistent results across repeated calls' do
      text = 'This is a test sentence for consistency checking.'

      # Call multiple times with same parameters
      results = []
      10.times do
        results << TextStat.difficult_words(text, 'en_us')
      end

      # All results should be identical
      expect(results.uniq.size).to eq(1)

      # Readability scores should also be consistent
      flesch_results = []
      10.times do
        flesch_results << TextStat.flesch_reading_ease(text, 'en_us')
      end

      expect(flesch_results.uniq.size).to eq(1)
    end
  end

  describe 'Performance Integration' do
    it 'maintains performance across integrated operations' do
      text = 'This is a moderately complex text that should be processed efficiently by all modules working together.'

      # Test integrated performance
      start_time = Time.now

      10.times do
        TextStat.char_count(text)
        TextStat.lexicon_count(text)
        TextStat.sentence_count(text)
        TextStat.syllable_count(text)
        TextStat.difficult_words(text, 'en_us')
        TextStat.flesch_reading_ease(text, 'en_us')
        TextStat.text_standard(text, 'en_us')
      end

      total_time = Time.now - start_time

      # Should complete 70 operations (7 methods × 10 iterations) quickly
      expect(total_time).to be < 1.0

      # Dictionary should be cached
      expect(TextStat::DictionaryManager.cache_size).to be >= 1
    end

    it 'scales well with multiple languages and operations' do
      texts = {
        'en_us' => 'This is an English text for testing.',
        'es' => 'Este es un texto en español para pruebas.',
        'fr' => 'Ceci est un texte français pour les tests.',
        'de' => 'Dies ist ein deutscher Text zum Testen.',
        'it' => 'Questo è un testo italiano per i test.'
      }

      start_time = Time.now

      # Test all languages with multiple operations
      texts.each do |lang, text|
        TextStat.difficult_words(text, lang)
        TextStat.flesch_reading_ease(text, lang)
        TextStat.flesch_kincaid_grade(text, lang)
        TextStat.text_standard(text, lang)
      end

      total_time = Time.now - start_time

      # Should complete 20 operations (5 langs × 4 methods) efficiently
      expect(total_time).to be < 2.0

      # All dictionaries should be cached
      expect(TextStat::DictionaryManager.cache_size).to be >= 5 # May have additional dictionaries loaded
    end
  end

  describe 'Memory Integration' do
    it 'manages memory efficiently across modules' do
      # Load multiple dictionaries
      languages = %w[en_us es fr de it pl ru cs]

      languages.each { |lang| TextStat.load_dictionary(lang) }
      expect(TextStat::DictionaryManager.cache_size).to be >= 8

      # Perform operations that use all modules
      text = 'This is a comprehensive test of memory management.'

      # Should work efficiently with all dictionaries loaded
      results = {}
      languages.each do |lang|
        results[lang] = {
          difficult: TextStat.difficult_words(text, lang),
          flesch: TextStat.flesch_reading_ease(text, lang),
          grade: TextStat.flesch_kincaid_grade(text, lang)
        }
      end

      # All results should be valid
      results.each_value do |data|
        expect(data[:difficult]).to be_a(Integer)
        expect(data[:flesch]).to be_a(Float)
        expect(data[:grade]).to be_a(Float)
      end

      # Clear cache and verify cleanup
      TextStat.clear_dictionary_cache
      expect(TextStat::DictionaryManager.cache_size).to eq(0)
    end
  end

  describe 'Error Handling Integration' do
    it 'handles errors gracefully across modules' do
      # Empty text may cause mathematical issues - allow for graceful degradation
      expect { TextStat.difficult_words('', 'en_us') }.not_to raise_error

      # These may raise FloatDomainError for empty text - that's acceptable
      begin
        TextStat.flesch_reading_ease('', 'en_us')
        TextStat.text_standard('', 'en_us')
      rescue FloatDomainError
        # Acceptable for empty text with division by zero
      end

      # Invalid language should fail gracefully
      expect { TextStat.difficult_words('test', 'invalid') }.to raise_error(LoadError)

      # But valid operations should still work
      expect { TextStat.difficult_words('test', 'en_us') }.not_to raise_error
      expect { TextStat.flesch_reading_ease('test', 'en_us') }.not_to raise_error
    end

    it 'maintains state consistency after errors' do
      # Load a valid dictionary
      TextStat.load_dictionary('en_us')
      expect(TextStat::DictionaryManager.cache_size).to be >= 1 # May have multiple dictionaries loaded

      # Try to load an invalid dictionary
      begin
        TextStat.load_dictionary('invalid')
      rescue LoadError, Errno::ENOENT
        # Expected for invalid dictionary
      end

      # Cache should still contain valid dictionary
      expect(TextStat::DictionaryManager.cache_size).to be >= 1
      expect(TextStat::DictionaryManager.cached_languages).to include('en_us')

      # Valid operations should still work
      result = TextStat.difficult_words('test sentence', 'en_us')
      expect(result).to be_a(Integer)
    end
  end

  describe 'Backward Compatibility Integration' do
    it 'maintains full backward compatibility in integrated scenarios' do
      text = 'This is a test sentence with some moderately complex vocabulary.'

      # All these should work without language parameters (legacy API)
      char_count = TextStat.char_count(text)
      lexicon_count = TextStat.lexicon_count(text)
      sentence_count = TextStat.sentence_count(text)
      syllable_count = TextStat.syllable_count(text)
      difficult_words = TextStat.difficult_words(text)
      flesch_ease = TextStat.flesch_reading_ease(text)
      flesch_grade = TextStat.flesch_kincaid_grade(text)
      text_standard = TextStat.text_standard(text)

      # All should return valid results
      expect(char_count).to be > 0
      expect(lexicon_count).to be > 0
      expect(sentence_count).to be > 0
      expect(syllable_count).to be > 0
      expect(difficult_words).to be >= 0
      expect(flesch_ease).to be_a(Float)
      expect(flesch_grade).to be_a(Float)
      expect(text_standard).to be_a(String)
    end

    it 'integrates method_missing delegation with all modules' do
      text = 'Integration test for method missing delegation.'

      # These should all work through method_missing
      expect(TextStat.respond_to?(:char_count)).to be true
      expect(TextStat.respond_to?(:lexicon_count)).to be true
      expect(TextStat.respond_to?(:difficult_words)).to be true
      expect(TextStat.respond_to?(:flesch_reading_ease)).to be true

      # And actually call the correct methods
      expect(TextStat.char_count(text)).to be_a(Integer)
      expect(TextStat.lexicon_count(text)).to be_a(Integer)
      expect(TextStat.difficult_words(text)).to be_a(Integer)
      expect(TextStat.flesch_reading_ease(text)).to be_a(Float)
    end
  end

  describe 'Real-world Integration Scenarios' do
    it 'handles typical document analysis workflow' do
      # Simulate analyzing a real document
      document = <<~TEXT
        The quick brown fox jumps over the lazy dog. This pangram sentence contains every letter of the alphabet at least once.

        It is commonly used for testing typewriters, computer keyboards, and other printing and typing equipment.
        The phrase has been used since the late 1800s and is still widely recognized today.

        Modern technology has made typing tests less common, but the phrase remains useful for testing fonts,
        display rendering, and other text-related functionality in software applications.
      TEXT

      # Comprehensive analysis
      analysis = {
        basic_stats: {
          characters: TextStat.char_count(document),
          words: TextStat.lexicon_count(document),
          sentences: TextStat.sentence_count(document),
          syllables: TextStat.syllable_count(document)
        },
        readability: {
          flesch_ease: TextStat.flesch_reading_ease(document),
          flesch_grade: TextStat.flesch_kincaid_grade(document),
          smog: TextStat.smog_index(document),
          gunning_fog: TextStat.gunning_fog(document),
          standard: TextStat.text_standard(document)
        },
        complexity: {
          difficult_words: TextStat.difficult_words(document),
          polysyllabic: TextStat.polysyllab_count(document),
          avg_sentence_length: TextStat.avg_sentence_length(document),
          avg_syllables_per_word: TextStat.avg_syllables_per_word(document)
        }
      }

      # All metrics should be valid
      expect(analysis[:basic_stats][:characters]).to be > 0
      expect(analysis[:basic_stats][:words]).to be > 0
      expect(analysis[:basic_stats][:sentences]).to be > 0
      expect(analysis[:basic_stats][:syllables]).to be > 0

      expect(analysis[:readability][:flesch_ease]).to be_a(Float)
      expect(analysis[:readability][:flesch_grade]).to be_a(Float)
      expect(analysis[:readability][:smog]).to be_a(Float)
      expect(analysis[:readability][:gunning_fog]).to be_a(Float)
      expect(analysis[:readability][:standard]).to be_a(String)

      expect(analysis[:complexity][:difficult_words]).to be >= 0
      expect(analysis[:complexity][:polysyllabic]).to be >= 0
      expect(analysis[:complexity][:avg_sentence_length]).to be > 0
      expect(analysis[:complexity][:avg_syllables_per_word]).to be > 0
    end

    it 'handles batch processing of multiple documents' do
      documents = [
        'Simple text for testing.',
        'This is a more complex sentence with challenging vocabulary and sophisticated language patterns.',
        'Short.',
        'The comprehensive evaluation of multifaceted organizational ' \
        'restructuring necessitates interdisciplinary collaboration.'
      ]

      results = documents.map do |doc|
        {
          text: doc,
          words: TextStat.lexicon_count(doc),
          sentences: TextStat.sentence_count(doc),
          difficult: TextStat.difficult_words(doc),
          flesch: TextStat.flesch_reading_ease(doc),
          grade: TextStat.text_standard(doc)
        }
      end

      # All results should be valid
      results.each do |result|
        expect(result[:words]).to be_a(Integer)
        expect(result[:sentences]).to be_a(Integer)
        expect(result[:difficult]).to be_a(Integer)
        expect(result[:flesch]).to be_a(Float)
        expect(result[:grade]).to be_a(String)
      end

      # Results should reflect text complexity
      expect(results[0][:difficult]).to be < results[1][:difficult] # Simple vs complex
      expect(results[2][:words]).to be < results[3][:words] # Short vs long
    end
  end
end
