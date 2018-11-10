class Counter < Hash
  def initialize(other = nil)
    super(0)
    other.each { |e| self[e] += 1 } if other.is_a? Array
    other.each { |k, v| self[k] = v } if other.is_a? Hash
    other.each_char { |e| self[e] += 1 } if other.is_a? String
  end

  def +(rhs)
    raise TypeError, "cannot add #{rhs.class} to a Counter" unless rhs.is_a? Counter

    result = Counter.new(self)
    rhs.each { |k, v| result[k] += v }
    result
  end

  def -(rhs)
    raise TypeError, "cannot subtract #{rhs.class} to a Counter" unless rhs.is_a? Counter

    result = Counter.new(self)
    rhs.each { |k, v| result[k] -= v }
    result
  end

  def most_common(n = nil)
    s = sort_by { |_k, v| -v }
    n ? s.take(n) : s
  end

  def to_s
    "Counter(#{super})"
  end

  def inspect
    to_s
  end
end
