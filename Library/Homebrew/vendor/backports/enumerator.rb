require 'vendor/backports'
require 'enumerator'

unless Object.const_defined? :Enumerator
  Backports.make_block_optional Enumerable::Enumerator, :each, :test_on => [42].to_enum
  Backports.make_block_optional Array, :each, :test_on => [42]

  unless Enumerable::Enumerator.method_defined? :next
    class Enumerable::Enumerator
      require 'vendor/backports/stop_iteration'

      def next
        require 'generator'
        @generator ||= ::Generator.new(self)
        raise StopIteration unless @generator.next?
        @generator.next
      end
    end
  end

  unless Enumerable::Enumerator.method_defined? :rewind
    class Enumerable::Enumerator
      def rewind
        require 'generator'
        @generator ||= ::Generator.new(self)
        @generator.rewind
        self
      end
    end
  end

  unless Enumerable::Enumerator.method_defined? :with_index
    class Enumerable::Enumerator
      def with_index(offset = 0)
        return to_enum(:with_index, offset) unless block_given?
        each do |*args|
          yield args.size == 1 ? args[0] : args, offset
          offset += 1
        end
      end
    end
  end
end

Enumerator = Enumerable::Enumerator
