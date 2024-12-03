# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day03
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      input.map do |line|
        extract_mult_operations(line)
      end.flatten.map(&:result).reduce(:+)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: String).returns(T::Array[Multiply]) }
    def extract_mult_operations(input)
      input.scan(Multiply::FORMAT).map do |operation|
        operation = T.cast(operation, [String, String])
        val1, val2 = operation

        Multiply.new(val1.to_i, val2.to_i)
      end.compact
    end
  end

  class Multiply
    extend T::Sig

    FORMAT = T.let(/mul\((\d{1,3}),(\d{1,3})\)/, Regexp)

    sig { returns(Integer) }
    attr_reader :result

    sig { params(val1: Integer, val2: Integer).void }
    def initialize(val1, val2)
      @val1 = T.let(val1, Integer)
      @val2 = T.let(val2, Integer)
      @result = T.let(@val1 * @val2, Integer)
    end
  end
end
