require 'rspec'
require_relative '../lib/textstat'

describe 'TextStat Multi-Language Support' do
  # All available languages with their codes and names
  LANGUAGES = {
    'ca' => 'Catalan',
    'cs' => 'Czech',
    'da' => 'Danish',
    'de' => 'German',
    'en_us' => 'English (US)',
    'en_uk' => 'English (UK)',
    'es' => 'Spanish',
    'et' => 'Estonian',
    'fi' => 'Finnish',
    'fr' => 'French',
    'hr' => 'Croatian',
    'hu' => 'Hungarian',
    'id' => 'Indonesian',
    'is' => 'Icelandic',
    'it' => 'Italian',
    'la' => 'Latin',
    'nl' => 'Dutch',
    'no2' => 'Norwegian (Bokmål)',
    'pl' => 'Polish',
    'pt' => 'Portuguese',
    'ru' => 'Russian',
    'sv' => 'Swedish',
    'ga' => 'Irish',
    'eu' => 'Basque'
  }.freeze

  # Test text samples in different languages
  TEST_TEXTS = {
    'en_us' => 'The quick brown fox jumps over the lazy dog. This is a simple test sentence.',
    'es' => 'El rápido zorro marrón salta sobre el perro perezoso. Esta es una oración de prueba simple.',
    'fr' => 'Le rapide renard brun saute par-dessus le chien paresseux. Ceci est une phrase de test simple.',
    'de' => 'Der schnelle braune Fuchs springt über den faulen Hund. Dies ist ein einfacher Testsatz.',
    'it' => 'La volpe marrone veloce salta sopra il cane pigro. Questa è una semplice frase di prova.',
    'pl' => 'Szybki brązowy lis przeskakuje przez leniwego psa. To jest proste zdanie testowe.',
    'ru' => 'Быстрая коричневая лиса прыгает через ленивую собаку. Это простое тестовое предложение.',
    'pt' => 'A raposa marrom rápida salta sobre o cão preguiçoso. Esta é uma frase de teste simples.',
    'nl' => 'De snelle bruine vos springt over de luie hond. Dit is een eenvoudige testzin.',
    'sv' => 'Den snabba bruna räven hoppar över den lata hunden. Detta är en enkel testmening.',
    'cs' => 'Rychlá hnědá liška skáče přes líného psa. Toto je jednoduchá testovací věta.',
    'da' => 'Den hurtige brune ræv springer over den dovne hund. Dette er en simpel testsætning.',
    'ga' => 'Léimeann an sionnach donn gasta thar an madra leisciúil. Seo abairt tástála shimplí eile.',
    'eu' => 'Azeri azkar marroiak txakur alferra gainetik egiten du jauzi. Hau proba esaldi sinple bat da.'
  }.freeze

  let(:default_text) { TEST_TEXTS['en_us'] }

  before do
    # Clear cache before each test to ensure clean state
    TextStat.clear_dictionary_cache
  end

  describe 'Dictionary Loading' do
    LANGUAGES.each do |code, name|
      it "loads #{name} (#{code}) dictionary successfully" do
        expect { TextStat.load_dictionary(code) }.not_to raise_error
        dictionary = TextStat.load_dictionary(code)
        expect(dictionary).to be_a(Set)
        expect(dictionary.size).to be > 0
      end
    end

    it 'caches dictionaries for performance' do
      expect(TextStat::DictionaryManager.cache_size).to eq(0)

      TextStat.load_dictionary('en_us')
      expect(TextStat::DictionaryManager.cache_size).to eq(1)

      TextStat.load_dictionary('fr')
      expect(TextStat::DictionaryManager.cache_size).to eq(2)

      expect(TextStat::DictionaryManager.cached_languages).to contain_exactly('en_us', 'fr')
    end
  end

  describe 'Basic Statistics Across Languages' do
    LANGUAGES.each do |code, name|
      context "#{name} (#{code})" do
        let(:text) { TEST_TEXTS[code] || default_text }

        it 'calculates syllable count' do
          skip 'Croatian language has text-hyphen compatibility issues' if code == 'hr'
          skip 'Norwegian language has text-hyphen compatibility issues' if code == 'no2'
          skip 'Irish language has text-hyphen compatibility issues' if code == 'ga'

          result = TextStat.syllable_count(text, code)
          expect(result).to be_a(Integer)
          expect(result).to be > 0
        end

        it 'calculates difficult words' do
          skip 'Croatian language has text-hyphen compatibility issues' if code == 'hr'
          skip 'Norwegian language has text-hyphen compatibility issues' if code == 'no2'
          skip 'Irish language has text-hyphen compatibility issues' if code == 'ga'

          result = TextStat.difficult_words(text, code)
          expect(result).to be_a(Integer)
          expect(result).to be >= 0
        end

        it 'calculates difficult words as set when requested' do
          skip 'Croatian language has text-hyphen compatibility issues' if code == 'hr'
          skip 'Norwegian language has text-hyphen compatibility issues' if code == 'no2'
          skip 'Irish language has text-hyphen compatibility issues' if code == 'ga'

          result = TextStat.difficult_words(text, code, true)
          expect(result).to be_a(Set)
        end

        it 'calculates readability formulas' do
          skip 'Croatian language has text-hyphen compatibility issues' if code == 'hr'
          skip 'Norwegian language has text-hyphen compatibility issues' if code == 'no2'
          skip 'Irish language has text-hyphen compatibility issues' if code == 'ga'

          expect { TextStat.flesch_reading_ease(text, code) }.not_to raise_error
          expect { TextStat.flesch_kincaid_grade(text, code) }.not_to raise_error
          expect { TextStat.smog_index(text, code) }.not_to raise_error
        end
      end
    end
  end

  describe 'Performance with Multiple Languages' do
    it 'efficiently handles multiple languages in sequence' do
      languages_to_test = %w[en_us es fr de it]

      start_time = Time.now

      languages_to_test.each do |lang|
        text = TEST_TEXTS[lang] || default_text
        5.times do
          TextStat.difficult_words(text, lang)
          TextStat.flesch_reading_ease(text, lang)
        end
      end

      end_time = Time.now
      total_time = end_time - start_time

      # Should complete 25 operations (5 langs × 5 iterations) in reasonable time
      expect(total_time).to be < 2.0 # Less than 2 seconds
      expect(TextStat::DictionaryManager.cache_size).to eq(5)
    end
  end

  describe 'Language-specific Edge Cases' do
    it 'handles languages with different character sets' do
      # Russian (Cyrillic)
      russian_text = 'Привет, как дела? Это тестовое предложение.'
      expect { TextStat.difficult_words(russian_text, 'ru') }.not_to raise_error

      # Test that it doesn't crash on non-ASCII characters
      result = TextStat.char_count(russian_text)
      expect(result).to be > 0
    end

    it 'handles languages with special characters' do
      # German (umlauts)
      german_text = 'Mädchen können wundervolle Geschichten erzählen.'
      expect { TextStat.difficult_words(german_text, 'de') }.not_to raise_error

      # French (accents)
      french_text = 'Les élèves étudient attentivement leurs leçons.'
      expect { TextStat.difficult_words(french_text, 'fr') }.not_to raise_error
    end
  end

  describe 'Dictionary Content Validation' do
    it 'ensures all dictionaries contain common words' do
      # Words that should exist in most language dictionaries
      common_test_cases = {
        'en_us' => %w[the and is was],
        'es' => %w[el la y es],
        'fr' => %w[le la et est],
        'de' => %w[der die und ist],
        'it' => %w[il la e è],
        'eu' => %w[eta da ez bai],
        'ga' => %w[an agus is ar]
      }

      common_test_cases.each do |lang, words|
        dictionary = TextStat.load_dictionary(lang)
        words.each do |word|
          expect(dictionary).to include(word),
                                "Dictionary for #{lang} should contain common word '#{word}'"
        end
      end
    end
  end
end
