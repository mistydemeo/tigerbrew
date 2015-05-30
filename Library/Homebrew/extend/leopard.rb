module Enumerable
  def group_by
    inject({}) do |h, e|
      h.fetch(yield(e)) { |k| h[k] = [] } << e; h
    end
  end
end

class String
  def start_with?(*prefixes)
    prefixes.any? do |prefix|
      if prefix.respond_to?(:to_str)
        prefix = prefix.to_str
        self[0, prefix.length] == prefix
      end
    end
  end

  def end_with?(*suffixes)
    suffixes.any? do |suffix|
      if suffix.respond_to?(:to_str)
        suffix = suffix.to_str
        self[-suffix.length, suffix.length] == suffix
      end
    end
  end

  def rpartition(separator)
    if ind = rindex(separator)
      [slice(0, ind), separator, slice(ind+1, -1) || '']
    else
      ['', '', dup]
    end
  end
end

class Symbol
  def to_proc
    proc { |*args| args.shift.send(self, *args) }
  end
end
