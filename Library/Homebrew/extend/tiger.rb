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
  def modifiable
    if self.frozen?
      raise TypeError, "can't modify frozen #{self.class}", caller(2)
    end
    @table
  end
  protected :modifiable

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

class String
  def rpartition(separator)
    if ind = rindex(separator)
      [slice(0, ind), separator, slice(ind+1, -1) || '']
    else
      ['', '', dup]
    end
  end
end

# Used in ExternalPatch#owner= in patch.rb
# Definition taken from Ruby 2.0, should be compatible
# with 1.8.6 and 1.8.7.
class ERB
  module Util
    def url_encode(s)
      s.to_s.b.gsub(/[^a-zA-Z0-9_\-.]/n) { |m|
        sprintf("%%%02X", m.unpack("C")[0])
      }
    end
    alias u url_encode
    module_function :u
    module_function :url_encode
  end
end
