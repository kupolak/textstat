require 'text-hyphen'

class TextStat
  def self.char_count(text, ignore_spaces = true)
    text = text.delete(' ') if ignore_spaces
    text.length
  end

  def self.lexicon_count(text, remove_punctuation = true)
    text  = text.gsub(/[^a-zA-Z\s]/, '').squeeze(' ') if remove_punctuation
    count = text.split(' ').count
    count
  end

  def self.syllable_count(text, language = 'en_us')
    return 0 if text.empty?

    text = text.downcase
    text.gsub(/[^a-zA-Z\s]/, '').squeeze(' ')
    dictionary = Text::Hyphen.new(language: language, left: 0, right: 0)
    count = 0
    text.split(' ').each do |word|
      word_hyphenated = dictionary.visualise(word)
      count += [1, word_hyphenated.count('-') + 1].max
    end
    count
  end

  def self.sentence_count(text)
    text.scan(/[\.\?!][\'\\)\]]*[ |\n][A-Z]/).map(&:strip).count + 1
  end

  def self.avg_sentence_length(text)
    asl = lexicon_count(text).to_f / sentence_count(text).to_f
    asl.round(1)
  rescue ZeroDivisionError
    0.0
  end
end