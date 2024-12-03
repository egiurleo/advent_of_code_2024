# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day03
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      Program.new(input.join).run.sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end
  end

  class Program
    extend T::Sig

    sig { params(input: String).void }
    def initialize(input)
      @operations = T.let([], T::Array[Operation])
      @program_state = T.let(ProgramState.new, ProgramState)

      input.scan(Multiply::FORMAT).map do |op_string|
        op_string = T.cast(op_string, String)

        op_string = op_string.delete_prefix('mul(').delete_suffix(')')
        val1, val2 = op_string.split(',')

        raise ArgumentError if val1.nil? || val2.nil?

        @operations << Multiply.new(val1.to_i, val2.to_i)
      end
    end

    sig { returns(Integer) }
    def sum
      @program_state.sum
    end

    sig { returns(Program) }
    def run
      @operations.each { |op| op.perform(@program_state) }
      self
    end
  end

  class ProgramState
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :sum

    sig { void }
    def initialize
      @sum = T.let(0, Integer)
      @mult_allowed = T.let(true, T::Boolean)
    end

    sig { params(val: Integer).void }
    def add(val)
      @sum += val
    end

    sig { void }
    def allow_mult
      @mult_allowed = true
    end

    sig { void }
    def disallow_mult
      @mult_allowed = false
    end

    sig { returns(T::Boolean) }
    def mult_allowed?
      @mult_allowed
    end
  end

  class Operation
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(state: ProgramState).void }
    def perform(state); end
  end

  class Multiply < Operation
    extend T::Sig

    FORMAT = T.let(/mul\(\d{1,3},\d{1,3}\)/, Regexp)

    sig { returns(Integer) }
    attr_reader :result

    sig { params(val1: Integer, val2: Integer).void }
    def initialize(val1, val2)
      super()

      @val1 = T.let(val1, Integer)
      @val2 = T.let(val2, Integer)
      @result = T.let(@val1 * @val2, Integer)
    end

    sig { override.params(state: ProgramState).void }
    def perform(state)
      state.add(@result)
    end
  end
end
