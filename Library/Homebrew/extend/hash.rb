class Hash
  # Hash isn't ordered in Ruby 1.8, but 1.8.7 nonetheless provides a
  # #first method. This is weird, but we use it in Homebrew for
  # single-length hashes.
  def first
    each { |el| break el }
  end unless method_defined?(:first)
end
