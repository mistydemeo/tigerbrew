# Extracted from the backports gem, by Marc-Andre Lafortune
# https://github.com/marcandre/backports
# 
# Copyright (c) 2009 Marc-Andre Lafortune
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Backports
  # Metaprogramming utility to make block optional.
  # Tests first if block is already optional when given options
  def self.make_block_optional(mod, *methods)
    mod = class << mod; self; end unless mod.is_a? Module
    options = methods.last.is_a?(Hash) ? methods.pop : {}
    methods.each do |selector|
      unless mod.method_defined? selector
        warn "#{mod}##{selector} is not defined, so block can't be made optional"
        next
      end
      unless options[:force]
        # Check if needed
        test_on = options.fetch(:test_on)
        result =  begin
                    test_on.send(selector, *options.fetch(:arg, []))
                  rescue LocalJumpError
                    false
                  end
        next if result.class.name =~ /Enumerator$/
      end
      require 'enumerator'
      arity = mod.instance_method(selector).arity
      last_arg = []
      if arity < 0
        last_arg = ["*rest"]
        arity = -1-arity
      end
      arg_sequence = ((0...arity).map{|i| "arg_#{i}"} + last_arg + ["&block"]).join(", ")

      alias_method_chain(mod, selector, :optional_block) do |aliased_target, punctuation|
        mod.module_eval <<-end_eval, __FILE__, __LINE__ + 1
          def #{aliased_target}_with_optional_block#{punctuation}(#{arg_sequence})
            return to_enum(:#{aliased_target}_without_optional_block#{punctuation}, #{arg_sequence}) unless block_given?
            #{aliased_target}_without_optional_block#{punctuation}(#{arg_sequence})
          end
        end_eval
      end
    end
  end

# Modified to avoid polluting Module if so desired
  # (from Rails)
  def self.alias_method_chain(mod, target, feature)
    mod.class_eval do
      # Strip out punctuation on predicates or bang methods since
      # e.g. target?_without_feature is not a valid method name.
      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
      yield(aliased_target, punctuation) if block_given?

      with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"

      alias_method without_method, target
      alias_method target, with_method

      case
        when public_method_defined?(without_method)
          public target
        when protected_method_defined?(without_method)
          protected target
        when private_method_defined?(without_method)
          private target
      end
    end
  end
end
