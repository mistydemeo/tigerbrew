module Enumerable
  def flat_map
    return to_enum(:flat_map) unless block_given?
    r = []
    each do |*args|
      result = yield(*args)
      result.respond_to?(:to_ary) ? r.concat(result) : r.push(result)
    end
    r
  end unless method_defined?(:flat_map)

  def group_by
    inject({}) do |h, e|
      h.fetch(yield(e)) { |k| h[k] = [] } << e; h
    end
  end unless method_defined?(:group_by)
end
