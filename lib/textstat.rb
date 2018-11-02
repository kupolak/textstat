class TextStat
  def self.char_count(text, ignore_spaces = true)
    text = text.delete(' ') if ignore_spaces
    text.length
  end
end