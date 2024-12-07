# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day07
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      equations = parse_input(input)
      equations.filter.with_index do |eq, _|
        eq.valid?
      end.map(&:solution).sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: T::Array[String]).returns(T::Array[Equation]) }
    def parse_input(input)
      input.map do |line|
        solution_str, test_values_str = line.split(':')
        test_values = T.must(test_values_str).split.map(&:to_i)

        Equation.new(solution_str.to_i, test_values)
      end
    end
  end

  class Equation
    extend T::Sig

    @@instances = T.let({}, T::Hash[T::Array[Integer], Equation])
    @@cache_hits = T.let(0, Integer)

    class << self
      extend T::Sig

      sig { params(solution: Integer, test_values: T::Array[Integer]).returns(Equation) }
      def new_or_cached(solution, test_values)
        key = [solution, *test_values]
        eq = @@instances[key]

        unless eq.nil?
          @@cache_hits += 1
          puts "Cache hit: #{solution}, #{test_values}!" if @@cache_hits % 500 == 0
          return eq
        end

        @@instances[key] = Equation.new(solution, test_values)
      end
    end

    sig { returns(Integer) }
    attr_reader :solution

    sig { params(solution: Integer, test_values: T::Array[Integer]).void }
    def initialize(solution, test_values)
      @solution = T.let(solution, Integer)
      @test_values = T.let(test_values, T::Array[Integer])
      @valid = T.let(nil, T.nilable(T::Boolean))
    end

    sig { returns(T::Boolean) }
    def valid?
      return @valid unless @valid.nil?

      return @valid = @test_values.sum == @solution || @test_values.reduce(&:*) == @solution if @test_values.length == 2

      new_test_values = @test_values.dup
      test_value = new_test_values.delete_at(@test_values.length - 1)

      raise if test_value.nil?

      # new_equation_sum = self.class.new_or_cached(@solution - test_value, new_test_values)
      # new_equation_mult = self.class.new_or_cached(@solution / test_value, new_test_values)
      new_equation_sum = Equation.new(@solution - test_value, new_test_values)
      new_equation_mult = Equation.new(@solution / test_value, new_test_values)

      should_test_mult = (@solution % test_value).zero?

      @valid = new_equation_sum.valid? || (should_test_mult && new_equation_mult.valid?)
    end
  end
end
