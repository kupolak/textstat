require 'text-hyphen'

class TextStat
  GEM_PATH = File.dirname(File.dirname(__FILE__))

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
      count += word_hyphenated.count('-') + 1
    end
    count
  end

  def self.sentence_count(text)
    text.scan(/[\.\?!][\'\\)\]]*[ |\n][A-Z]/).map(&:strip).count + 1
  end

  def self.avg_sentence_length(text)
    asl = lexicon_count(text).to_f / sentence_count(text)
    asl.round(1)
  rescue ZeroDivisionError
    0.0
  end

  def self.avg_syllables_per_word(text)
    syllable = syllable_count(text)
    words    = lexicon_count(text)
    begin
      syllables_per_word = syllable.to_f / words
      syllables_per_word.round(1)
    rescue ZeroDivisionError
      0.0
    end
  end

  def self.avg_letter_per_word(text)
    letters_per_word = char_count(text).to_f / lexicon_count(text)
    letters_per_word.round(2)
  rescue ZeroDivisionError
    0.0
  end

  def self.avg_sentence_per_word(text)
    sentence_per_word = sentence_count(text).to_f / lexicon_count(text)
    sentence_per_word.round(2)
  rescue ZeroDivisionError
    0.0
  end

  def self.flesch_reading_ease(text)
    sentence_length    = avg_sentence_length(text)
    syllables_per_word = avg_syllables_per_word(text)
    flesch = 206.835 - 1.015 * sentence_length - 84.6 * syllables_per_word
    flesch.round(2)
  end

  def self.flesch_kincaid_grade(text)
    sentence_length = avg_sentence_length(text)
    syllables_per_word = avg_syllables_per_word(text)
    flesch = 0.39 * sentence_length + 11.8 * syllables_per_word - 15.59
    flesch.round(1)
  end

  def self.polysyllab_count(text)
    count = 0
    text.split(' ').each do |word|
      w = syllable_count(word)
      count += 1 if w >= 3
    end
    count
  end

  def self.smog_index(text)
    sentences = sentence_count(text)

    if sentences >= 3
      begin
        polysyllab = polysyllab_count(text)
        smog = 1.043 * Math.sqrt(30.0 * polysyllab / sentences) + 3.1291
        smog.round(1)
      rescue ZeroDivisionError
        0.0
      end
    else
      0.0
    end
  end

  def self.coleman_liau_index(text)
    letters = (avg_letter_per_word(text) * 100).round(2)
    sentences = (avg_sentence_per_word(text) * 100).round(2)
    coleman = 0.0588 * letters - 0.296 * sentences - 15.8
    coleman.round(2)
  end

  def self.automated_readability_index(text)
    chars = char_count(text)
    words = lexicon_count(text)
    sentences = sentence_count(text)
    begin
      a = chars.to_f / words
      b = words.to_f / sentences

      readability = 4.71 * a + 0.5 * b - 21.43
      readability.round(1)
    rescue ZeroDivisionError
      0.0
    end
  end

  def self.linsear_write_formula(text)
    easy_word = 0
    difficult_word = 0
    text_list = text.split(' ')[0..100]

    text_list.each do |word|
      if syllable_count(word) < 3
        easy_word += 1
      else
        difficult_word += 1
      end
    end

    text = text_list.join(' ')

    number = (easy_word * 1 + difficult_word * 3).to_f / sentence_count(text)
    number -= 2 if number <= 20
    number / 2
  end

  def self.difficult_words(text, language = 'en_us')
    require 'set'
    easy_words = Set.new
    File.read(File.join(dictionary_path, "#{language}.txt")).each_line do |line|
      easy_words << line.chop
    end

    text_list = text.downcase.gsub(/[^0-9a-z ]/i, '').split(' ')
    diff_words_set = Set.new
    text_list.each do |value|
      next if easy_words.include? value

      diff_words_set.add(value) if syllable_count(value) > 1
    end
    diff_words_set.length
  end

  def self.dale_chall_readability_score(text)
    word_count = lexicon_count(text)
    count = word_count - difficult_words(text)

    begin
      per = 100.0 * count / word_count
    rescue ZeroDivisionError
      return 0.0
    end

    difficult_words = 100 - per
    score = 0.1579 * difficult_words + 0.0496 * avg_sentence_length(text)
    score += 3.6365 if difficult_words > 5

    score.round(2)
  end

  def self.gunning_fog(text)
    per_diff_words = 100.0 * difficult_words(text) / lexicon_count(text) + 5
    grade = 0.4 * (avg_sentence_length(text) + per_diff_words)

    grade.round(2)
  rescue ZeroDivisionError
    0.0
  end

  def self.lix(text)
    words = text.split(' ')
    words_length = words.length
    long_words = words.count { |word| word.length > 6 }

    per_long_words = 100.0 * long_words / words_length
    asl = avg_sentence_length(text)
    lix = asl + per_long_words

    lix.round(2)
  end

  def self.forcast(text, language = 'en_us')
    words = text.split(' ')[0..149]
    words_with_one_syllabe = words.count {
      |word| syllable_count(word, language) == 1
    }
    forcast = 20 - (words_with_one_syllabe / 10)
    forcast
  end

  def self.powers_sumner_kearl(text)
    grade = 0.0778 * avg_sentence_length(text) + 0.0455 * syllable_count(text) - 2.2029
    grade.round(2)
  end

  def self.spache(text, language = 'en_us')
    words = text.split(' ').count
    unfamiliar_words = difficult_words(text, language) / words
    grade = (0.141 * avg_sentence_length(text)) + (0.086 * unfamiliar_words) + 0.839
    grade.round(2)
  end

  def self.text_standard(text, float_output=nil)
    grade = []

    lower = flesch_kincaid_grade(text).round
    upper = flesch_kincaid_grade(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Flesch Reading Easy
    score = flesch_reading_ease(text)
    if score < 100 && score >= 90
      grade.append(5)
    elsif score < 90 && score >= 80
      grade.append(6)
    elsif score < 80 && score >= 70
      grade.append(7)
    elsif score < 70 && score >= 60
      grade.append(8)
      grade.append(9)
    elsif score < 60 && score >= 50
      grade.append(10)
    elsif score < 50 && score >= 40
      grade.append(11)
    elsif score < 40 && score >= 30
      grade.append(12)
    else
      grade.append(13)
    end

    # Appending SMOG Index
    lower = smog_index(text).round
    upper = smog_index(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Coleman_Liau_Index
    lower = coleman_liau_index(text).round
    upper = coleman_liau_index(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Automated_Readability_Index
    lower = automated_readability_index(text).round
    upper = automated_readability_index(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Dale_Chall_Readability_Score
    lower = dale_chall_readability_score(text).round
    upper = dale_chall_readability_score(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Linsear_Write_Formula
    lower = linsear_write_formula(text).round
    upper = linsear_write_formula(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Appending Gunning Fog Index
    lower = gunning_fog(text).round
    upper = gunning_fog(text).ceil
    grade.append(lower.to_i)
    grade.append(upper.to_i)

    # Finding the Readability Consensus based upon all the above tests
    require 'counter'
    d = Counter.new(grade)
    final_grade = d.most_common(1)
    score = final_grade[0][0]

    if float_output
      score.to_f
    else
      "#{score.to_i - 1}th and #{score.to_i}th grade"
    end
  end

  def self.dictionary_path=(path)
    @dictionary_path = path
  end

  def self.dictionary_path
    @dictionary_path ||= File.join(TextStat::GEM_PATH, 'lib', 'dictionaries')
  end
end
