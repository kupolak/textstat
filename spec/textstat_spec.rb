require 'rspec'
require_relative '../lib/textstat.rb'

describe TextStat do
  before do
    @long_test = 'Playing ... games has always been thought to be ' \
       'important to the development of well-balanced and ' \
       'creative children; however, what part, if any, ' \
       'they should play in the lives of adults has never ' \
       'been researched that deeply. I believe that ' \
       'playing games is every bit as important for adults ' \
       'as for children. Not only is taking time out to ' \
       'play games with our children and other adults ' \
       'valuable to building interpersonal relationships ' \
       'but is also a wonderful way to release built up ' \
       "tension.\n" \
       "There's nothing my husband enjoys more after a " \
       'hard day of work than to come home and play a game ' \
       'of Chess with someone. This enables him to unwind ' \
       "from the day's activities and to discuss the highs " \
       'and lows of the day in a non-threatening, kick back ' \
       'environment. One of my most memorable wedding ' \
       'gifts, a Backgammon set, was received by a close ' \
       'friend. I asked him why in the world he had given ' \
       'us such a gift. He replied that he felt that an ' \
       'important aspect of marriage was for a couple to ' \
       'never quit playing games together. Over the years, ' \
       'as I have come to purchase and play, with other ' \
       'couples & coworkers, many games like: Monopoly, ' \
       'Chutes & Ladders, Mastermind, Dweebs, Geeks, & ' \
       'Weirdos, etc. I can reflect on the integral part ' \
       'they have played in our weekends and our ' \
       '"shut-off the T.V. and do something more ' \
       'stimulating" weeks. They have enriched my life and ' \
       'made it more interesting. Sadly, many adults ' \
       'forget that games even exist and have put them ' \
       'away in the cupboards, forgotten until the ' \
       "grandchildren come over.\n" \
       'All too often, adults get so caught up in working ' \
       'to pay the bills and keeping up with the ' \
       "\"Joneses'\" that they neglect to harness the fun " \
       'in life; the fun that can be the reward of ' \
       'enjoying a relaxing game with another person. It ' \
       'has been said that "man is that he might have ' \
       'joy" but all too often we skate through life ' \
       'without much of it. Playing games allows us to: ' \
       'relax, learn something new and stimulating, ' \
       'interact with people on a different more ' \
       'comfortable level, and to enjoy non-threatening ' \
       'competition. For these reasons, adults should ' \
       'place a higher priority on playing games in their ' \
       'lives'
  end

  context 'When testing the TextStat class' do
    it 'should return the correct number of chars' do
      count = TextStat.char_count(@long_test)
      count_spaces = TextStat.char_count(@long_test, false)

      expect(count).to eql 1750
      expect(count_spaces).to eql 2123
    end

    it 'should return the correct number of lexicons' do
      count = TextStat.lexicon_count(@long_test)
      count_punctuation = TextStat.lexicon_count(@long_test, false)

      expect(count).to eql 372
      expect(count_punctuation).to eql 376
    end

    it 'should return the correct number of syllables' do
      count = TextStat.syllable_count(@long_test)
      expect(count).to eql 559
    end

    it 'should return the correct number of sentences' do
      count = TextStat.sentence_count(@long_test)
      expect(count).to eql 16
    end

    it 'should return the correct average sentence length' do
      avg = TextStat.avg_sentence_length(@long_test)
      expect(avg).to eql 23.3
    end

    it 'should return the correct average syllables per word' do
      avg = TextStat.avg_syllables_per_word(@long_test)
      expect(avg).to eql 1.5
    end

    it 'should return the correct average letters per word' do
      avg = TextStat.avg_letter_per_word(@long_test)
      expect(avg).to eql 4.7
    end

    it 'should return the correct average sentence per word' do
      avg = TextStat.avg_sentence_per_word(@long_test)
      expect(avg).to eql 0.04
    end

    it 'should return the correct Flesch reading-ease test score' do
      score = TextStat.flesch_reading_ease(@long_test)
      expect(score).to eql 56.29
    end

    it 'should return the correct Flesch–Kincaid grade' do
      score = TextStat.flesch_kincaid_grade(@long_test)
      expect(score).to eql 11.2
    end

    it 'should return the correct number of polysyllab' do
      count = TextStat.polysyllab_count(@long_test)
      expect(count).to eql 43
    end

    it 'should return the correct smog index' do
      index = TextStat.smog_index(@long_test)
      expect(index).to eql 12.5
    end

    it 'should return the correct Coleman–Liau index' do
      index = TextStat.coleman_liau_index(@long_test)
      expect(index).to eql 10.65
    end

    it 'should return the correct automated readability index' do
      index = TextStat.automated_readability_index(@long_test)
      expect(index).to eql 12.4
    end

    it 'should return the correct linsear write formula result' do
      result = TextStat.linsear_write_formula(@long_test)
      expect(result).to eql 14.875
    end

    it 'should return the correct difficult words result' do
      result = TextStat.difficult_words(@long_test)
      expect(result).to eql 58
    end

    it 'should return the correct Dale–Chall readability score' do
      score = TextStat.dale_chall_readability_score(@long_test)
      expect(score).to eql 7.25
    end

    it 'should return the correct Gunning fog score' do
      score = TextStat.gunning_fog(@long_test)
      expect(score).to eql 17.56
    end

    it 'should return the correct Lix readability test score' do
      score = TextStat.lix(@long_test)
      expect(score).to eql 45.11
    end

    it 'should return the correct FORCAST readability test score' do
      score = TextStat.forcast(@long_test)
      expect(score).to eql 10
    end

    it 'should return the correct Powers Sumner Kearl readability test score' do
      score = TextStat.powers_sumner_kearl(@long_test)
      expect(score).to eql 25.04
    end

    it 'should return the correct SPACHE readability test score' do
      score = TextStat.spache(@long_test)
      expect(score).to eql 4.12
    end

    it 'should return the readability consensus score' do
      standard = TextStat.text_standard(@long_test)
      expect(standard).to eql '10th and 11th grade'
    end

    describe '.dictionary_path' do
      subject(:dictionary_path) { described_class.dictionary_path }

      it 'returns the Gem dictionary path by default' do
        gem_root = File.dirname(File.dirname(__FILE__))
        default_path = File.join(gem_root, 'lib', 'dictionaries')
        expect(dictionary_path).to eq default_path
      end

      it 'allows dictionary path to be overridden' do
        described_class.dictionary_path = '/some/other/path'
        expect(dictionary_path).to eq '/some/other/path'
      end
    end
  end
end