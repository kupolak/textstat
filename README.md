# Texstat 
Ruby gem to calculate statistics from text to determine readability, complexity and grade level of a particular corpus.

Translation based on Python textstat library by @shivam5992 and other contributors. Thanks for making this world more open sourced :heart:

## Usage

```ruby
require 'textstat'

test_data = %(
         Playing games has always been thought to be important to 
        the development of well-balanced and creative children 
        however, what part, if any, they should play in the lives 
        of adults has never been researched that deeply. I believe 
        that playing games is every bit as important for adults 
        as for children. Not only is taking time out to play games 
        with our children and other adults valuable to building 
        interpersonal relationships but is also a wonderful way 
        to release built up tension.
)


TextStat.flesch_reading_ease(test_data)
TextStat.smog_index(test_data)
TextStat.flesch_kincaid_grade(test_data)
TextStat.coleman_liau_index(test_data)
TextStat.automated_readability_index(test_data)
TextStat.dale_chall_readability_score(test_data)
TextStat.difficult_words(test_data)
TextStat.linsear_write_formula(test_data)
TextStat.gunning_fog(test_data)
TextStat.text_standard(test_data)
```

The argument (text) for all the defined functions remains the same -
i.e the text for which statistics need to be calculated.
