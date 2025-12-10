module TextStat
  # Readability formulas and text difficulty calculations
  #
  # This module implements various readability formulas used to determine
  # the reading level and complexity of text. Each formula uses different
  # metrics and is suitable for different types of content and audiences.
  #
  # @author Jakub Polak
  # @since 1.0.0
  # @example Basic readability analysis
  #   text = "This is a sample text for readability analysis."
  #   TextStat.flesch_reading_ease(text)      # => 83.32
  #   TextStat.flesch_kincaid_grade(text)     # => 3.7
  #   TextStat.text_standard(text)            # => "3rd and 4th grade"
  #
  # @example Multi-language support
  #   TextStat.flesch_reading_ease(spanish_text, 'es')
  #   TextStat.smog_index(french_text, 'fr')
  #   TextStat.gunning_fog(german_text, 'de')
  module ReadabilityFormulas
    # Calculate Flesch Reading Ease score
    #
    # The Flesch Reading Ease formula produces a score between 0 and 100,
    # with higher scores indicating easier readability.
    #
    # Score ranges:
    # - 90-100: Very Easy
    # - 80-89: Easy
    # - 70-79: Fairly Easy
    # - 60-69: Standard
    # - 50-59: Fairly Difficult
    # - 30-49: Difficult
    # - 0-29: Very Difficult
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for syllable counting
    # @return [Float] Flesch Reading Ease score
    # @example
    #   TextStat.flesch_reading_ease("The cat sat on the mat.")  # => 116.15
    #   TextStat.flesch_reading_ease("Comprehensive analysis.")  # => 43.73
    def flesch_reading_ease(text, language = 'en_us')
      sentence_length = avg_sentence_length(text)
      syllables_per_word = avg_syllables_per_word(text, language)
      flesch = 206.835 - (1.015 * sentence_length) - (84.6 * syllables_per_word)
      flesch.round(2)
    end

    # Calculate Flesch-Kincaid Grade Level
    #
    # This formula converts the Flesch Reading Ease score into a U.S. grade level,
    # making it easier to understand the education level required to comprehend the text.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for syllable counting
    # @return [Float] grade level (e.g., 8.5 = 8th to 9th grade)
    # @example
    #   TextStat.flesch_kincaid_grade("Simple text.")      # => 2.1
    #   TextStat.flesch_kincaid_grade("Complex analysis.") # => 5.8
    def flesch_kincaid_grade(text, language = 'en_us')
      sentence_length = avg_sentence_length(text)
      syllables_per_word = avg_syllables_per_word(text, language)
      flesch = (0.39 * sentence_length) + (11.8 * syllables_per_word) - 15.59
      flesch.round(1)
    end

    # Calculate SMOG Index (Simple Measure of Gobbledygook)
    #
    # SMOG estimates the years of education needed to understand a text.
    # It focuses on polysyllabic words and is particularly useful for health
    # and educational materials.
    #
    # @param text [String] the text to analyze (minimum 3 sentences)
    # @param language [String] language code for syllable counting
    # @return [Float] SMOG grade level
    # @example
    #   TextStat.smog_index("The quick brown fox jumps. It is fast. Very agile.")  # => 8.2
    def smog_index(text, language = 'en_us')
      sentences = sentence_count(text)

      if sentences >= 3
        polysyllab = polysyllab_count(text, language)
        smog = (1.043 * Math.sqrt((30.0 * polysyllab) / sentences)) + 3.1291
        smog.round(1)
      else
        0.0
      end
    rescue ZeroDivisionError
      0.0
    end

    # Calculate Coleman-Liau Index
    #
    # This formula relies on character counts instead of syllable counts,
    # making it more suitable for automated analysis. It estimates the
    # U.S. grade level required to understand the text.
    #
    # @param text [String] the text to analyze
    # @return [Float] Coleman-Liau grade level
    # @example
    #   TextStat.coleman_liau_index("Short words are easy to read.")  # => 4.71
    def coleman_liau_index(text)
      letters = (avg_letter_per_word(text) * 100).round(2)
      sentences = (avg_sentence_per_word(text) * 100).round(2)
      coleman = (0.0588 * letters) - (0.296 * sentences) - 15.8
      coleman.round(2)
    end

    # Calculate Automated Readability Index (ARI)
    #
    # ARI uses character counts and word lengths to estimate readability.
    # It's designed to be easily calculated by computer programs.
    #
    # @param text [String] the text to analyze
    # @return [Float] ARI grade level
    # @example
    #   TextStat.automated_readability_index("This text is easy to read.")  # => 2.9
    def automated_readability_index(text)
      chars = char_count(text)
      words = lexicon_count(text)
      sentences = sentence_count(text)

      a = chars.to_f / words
      b = words.to_f / sentences
      readability = (4.71 * a) + (0.5 * b) - 21.43
      readability.round(1)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate Linsear Write Formula
    #
    # This formula is designed for technical writing and focuses on
    # the percentage of words with three or more syllables.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for syllable counting
    # @return [Float] Linsear Write grade level
    # @example
    #   TextStat.linsear_write_formula("Technical documentation analysis.")  # => 6.5
    def linsear_write_formula(text, language = 'en_us')
      easy_word = 0
      difficult_word = 0
      text_list = text.split[0..100]

      text_list.each do |word|
        if syllable_count(word, language) < 3
          easy_word += 1
        else
          difficult_word += 1
        end
      end

      text = text_list.join(' ')
      number = ((easy_word * 1) + (difficult_word * 3)).to_f / sentence_count(text)
      number -= 2 if number <= 20
      number / 2
    end

    # Calculate Dale-Chall Readability Score
    #
    # This formula uses a list of 3000 familiar words to determine text difficulty.
    # It's particularly effective for elementary and middle school texts.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for dictionary selection
    # @return [Float] Dale-Chall readability score
    # @example
    #   TextStat.dale_chall_readability_score("Simple story for children.")  # => 5.12
    def dale_chall_readability_score(text, language = 'en_us')
      word_count = lexicon_count(text)
      count = word_count - difficult_words(text, language)

      per = (100.0 * count) / word_count
      difficult_words_percentage = 100 - per
      score = (0.1579 * difficult_words_percentage) + (0.0496 * avg_sentence_length(text))
      score += 3.6365 if difficult_words_percentage > 5

      score.round(2)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate Gunning Fog Index
    #
    # The Fog Index estimates the years of formal education needed to understand
    # the text. It focuses on sentence length and polysyllabic words.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for syllable counting
    # @return [Float] Gunning Fog grade level
    # @example
    #   TextStat.gunning_fog("Business communication analysis.")  # => 12.3
    def gunning_fog(text, language = 'en_us')
      per_diff_words = ((100.0 * difficult_words(text, language)) / lexicon_count(text)) + 5
      grade = 0.4 * (avg_sentence_length(text) + per_diff_words)
      grade.round(2)
    rescue ZeroDivisionError
      0.0
    end

    # Calculate LIX Readability Formula
    #
    # LIX (Läsbarhetsindex) is a Swedish readability formula that works well
    # for multiple languages. It uses sentence length and percentage of long words.
    #
    # @param text [String] the text to analyze
    # @return [Float] LIX readability score
    # @example
    #   TextStat.lix("International readability measurement.")  # => 45.2
    def lix(text)
      words = text.split
      words_length = words.length
      long_words = words.count { |word| word.length > 6 }

      per_long_words = (100.0 * long_words) / words_length
      asl = avg_sentence_length(text)
      lix = asl + per_long_words
      lix.round(2)
    end

    # Calculate FORCAST Readability Formula
    #
    # FORCAST (FOg Readability by CASTing) is designed for technical materials
    # and focuses on single-syllable words to determine readability.
    #
    # @param text [String] the text to analyze (uses first 150 words)
    # @param language [String] language code for syllable counting
    # @return [Integer] FORCAST grade level
    # @example
    #   TextStat.forcast("Technical manual instructions.")  # => 11
    def forcast(text, language = 'en_us')
      words = text.split[0..149]
      words_with_one_syllabe = words.count do |word|
        syllable_count(word, language) == 1
      end
      20 - (words_with_one_syllabe / 10)
    end

    # Calculate Powers-Sumner-Kearl Readability Formula
    #
    # This formula was developed for primary-grade reading materials and
    # uses sentence length and syllable count to determine grade level.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for syllable counting
    # @return [Float] Powers-Sumner-Kearl grade level
    # @example
    #   TextStat.powers_sumner_kearl("Elementary school reading material.")  # => 4.2
    def powers_sumner_kearl(text, language = 'en_us')
      grade = (0.0778 * avg_sentence_length(text)) + (0.0455 * syllable_count(text, language)) - 2.2029
      grade.round(2)
    end

    # Calculate SPACHE Readability Formula
    #
    # The SPACHE formula is designed for primary-grade reading materials
    # (grades 1-4) and uses a list of familiar words for analysis.
    #
    # @param text [String] the text to analyze
    # @param language [String] language code for dictionary selection
    # @return [Float] SPACHE grade level
    # @example
    #   TextStat.spache("Primary school reading text.")  # => 2.8
    def spache(text, language = 'en_us')
      words = text.split.count
      unfamiliar_words = difficult_words(text, language) / words
      grade = (0.141 * avg_sentence_length(text)) + (0.086 * unfamiliar_words) + 0.839
      grade.round(2)
    end

    # Calculate consensus text standard from multiple formulas
    #
    # This method combines results from multiple readability formulas to provide
    # a consensus grade level recommendation. It's more reliable than using
    # a single formula alone.
    #
    # @param text [String] the text to analyze
    # @param float_output [Boolean] whether to return numeric grade or description
    # @return [String, Float] grade level description or numeric value
    # @example
    #   TextStat.text_standard("Sample text for analysis.")        # => "5th and 6th grade"
    #   TextStat.text_standard("Sample text for analysis.", true)  # => 5.0
    def text_standard(text, float_output = nil)
      grade = []

      # Collect grades from all formulas
      add_flesch_kincaid_grades(text, grade)
      add_flesch_reading_ease_grade(text, grade)
      add_other_readability_grades(text, grade)

      # Find consensus grade
      final_grade = calculate_consensus_grade(grade)

      format_grade_output(final_grade, float_output)
    end

    private

    # Add Flesch-Kincaid grade levels to grade array
    def add_flesch_kincaid_grades(text, grade)
      flesch_grade = flesch_kincaid_grade(text)
      grade.append(flesch_grade.round.to_i)
      grade.append(flesch_grade.ceil.to_i)
    end

    # Add Flesch Reading Ease grade level to grade array
    def add_flesch_reading_ease_grade(text, grade)
      score = flesch_reading_ease(text)
      case score
      when 90...100
        grade.append(5)
      when 80...90
        grade.append(6)
      when 70...80
        grade.append(7)
      when 60...70
        grade.append(8, 9)
      when 50...60
        grade.append(10)
      when 40...50
        grade.append(11)
      when 30...40
        grade.append(12)
      else
        grade.append(13)
      end
    end

    # Add other readability formula grades to grade array
    def add_other_readability_grades(text, grade)
      readability_scores = [
        smog_index(text),
        coleman_liau_index(text),
        automated_readability_index(text),
        dale_chall_readability_score(text),
        linsear_write_formula(text),
        gunning_fog(text)
      ]

      readability_scores.each do |score|
        grade.append(score.round.to_i)
        grade.append(score.ceil.to_i)
      end
    end

    # Calculate consensus grade from all collected grades
    # Uses Ruby's built-in tally method for better performance (Ruby 2.7+)
    def calculate_consensus_grade(grade)
      # Use tally to count occurrences - more efficient than Counter
      tallied = grade.tally
      # Find the grade with maximum count
      tallied.max_by { |_grade, count| count }[0]
    end

    # Format grade output based on float_output parameter
    def format_grade_output(grade, float_output)
      if float_output
        grade.to_f
      else
        "#{grade.to_i - 1}th and #{grade.to_i}th grade"
      end
    end
  end
end
