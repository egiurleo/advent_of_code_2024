# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day07
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      equations = parse_input(input)
      equations.filter(&:valid?).map(&:solution).sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      equations = parse_input(input, check_concat: true)
      equations.filter(&:valid?).map(&:solution).sum
    end

    private

    sig { params(input: T::Array[String], check_concat: T::Boolean).returns(T::Array[Equation]) }
    def parse_input(input, check_concat: false)
      input.map do |line|
        solution_str, test_values_str = line.split(':')
        test_values = T.must(test_values_str).split.map(&:to_i)

        Equation.new(solution_str.to_i, test_values, check_concat: check_concat)
      end
    end
  end

  class Equation
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :solution

    sig { params(solution: Integer, test_values: T::Array[Integer], check_concat: T::Boolean).void }
    def initialize(solution, test_values, check_concat: false)
      @solution = T.let(solution, Integer)
      @test_values = T.let(test_values, T::Array[Integer])
      @check_concat = T.let(check_concat, T::Boolean)
    end

    sig { returns(T::Boolean) }
    def valid?
      valid_through_addition? || valid_through_multiplication? || valid_through_concatination?
    end

    private

    sig { returns(T::Boolean) }
    def valid_through_addition?
      return @test_values.sum == @solution if base_case?

      addition_eq.valid?
    end

    sig { returns(T::Boolean) }
    def valid_through_multiplication?
      return @test_values.reduce(1, &:*) == @solution if base_case?

      multiplication_eq.valid?
    end

    sig { returns(T::Boolean) }
    def valid_through_concatination?
      return false unless @check_concat

      return @test_values.map(&:to_s).join.to_i == @solution if base_case?

      concatination_eq.valid?
    end

    sig { returns(T::Boolean) }
    def base_case?
      @test_values.length == 2
    end

    sig { returns(Equation) }
    def addition_eq
      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?

      Equation.new(@solution - test_value, new_test_values, check_concat: @check_concat)
    end

    sig { returns(Equation) }
    def multiplication_eq
      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?
      return InvalidEquation.create unless (@solution % test_value).zero?

      Equation.new(@solution / test_value, new_test_values, check_concat: @check_concat)
    end

    sig { returns(Equation) }
    def concatination_eq
      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?
      return InvalidEquation.create unless @solution.to_s.end_with?(test_value.to_s)

      Equation.new(@solution.to_s.delete_suffix(test_value.to_s).to_i, new_test_values, check_concat: @check_concat)
    end
  end

  class InvalidEquation < Equation
    extend T::Sig

    class << self
      extend T::Sig

      sig { returns(InvalidEquation) }
      def create
        new(0, [])
      end
    end

    sig { override.returns(FalseClass) }
    def valid?
      false
    end
  end
end
