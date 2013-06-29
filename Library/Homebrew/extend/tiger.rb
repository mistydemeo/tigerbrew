require 'ostruct'

# This file contains a set of monkeypatches to backport modern Ruby
# features into Tiger's ancient 1.8.2

class Object
  def instance_variable_defined?(ivar)
    if ivar.to_s !~ /^@/
      raise NameError, "`#{ivar}' is not allowed as an instance variable name"
    end

    instance_variables.include?(ivar.to_s)
  end
end

module Enumerable
  def one?(&block)
    return map.size == 1 unless block
    select(&block).size == 1
  end
end

module Kernel
  def Pathname(target)
    Pathname.new(target)
  end
end

# OpenStruct in 1.8.2 uses eval to generate member getters/setters, which
# results in hilarious syntax errors if a member ends with an exclamation
# mark or a question mark. e.g.:
# def #{name}=(x); @table[:#{name}] = x; end
# Becomes:
# def all?=(x); @table[:all?] = x; end
# This notably breaks brew-deps. 1.8.7 more sensibly uses define_method.
# This method is backported exactly from 1.8.7's definition.
class OpenStruct
  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) { @table[name] }
        define_method("#{name}=") { |x| modifiable[name] = x }
      end
    end
    name
  end
end
