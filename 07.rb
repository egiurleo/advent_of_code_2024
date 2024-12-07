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
      equations = parse_input(input)
      equations.filter { |eq| eq.valid?(with_concat: true) }.map(&:solution).sum
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

    sig { returns(Integer) }
    attr_reader :solution

    sig { params(solution: Integer, test_values: T::Array[Integer]).void }
    def initialize(solution, test_values)
      @solution = T.let(solution, Integer)
      @test_values = T.let(test_values, T::Array[Integer])
    end

    sig { params(with_concat: T::Boolean).returns(T::Boolean) }
    def valid?(with_concat: false)
      valid_through_addition?(with_concat: with_concat) || valid_through_multiplication?(with_concat: with_concat) ||
        valid_through_concatination?(with_concat: with_concat)
    end

    private

    sig { params(with_concat: T::Boolean).returns(T::Boolean) }
    def valid_through_addition?(with_concat: false)
      return @test_values.sum == @solution if base_case?

      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?

      addition_eq = Equation.new(@solution - test_value, new_test_values)
      addition_eq.valid?(with_concat: with_concat)
    end

    sig { params(with_concat: T::Boolean).returns(T::Boolean) }
    def valid_through_multiplication?(with_concat: false)
      return @test_values.reduce(1, &:*) == @solution if base_case?

      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?

      possible_multiplication = (@solution % test_value).zero?
      multiplication_eq = Equation.new(@solution / test_value, new_test_values)

      possible_multiplication && multiplication_eq.valid?(with_concat: with_concat)
    end

    sig { params(with_concat: T::Boolean).returns(T::Boolean) }
    def valid_through_concatination?(with_concat: false)
      return false unless with_concat

      return @test_values.map(&:to_s).join.to_i == @solution if base_case?

      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      possible_concatination = @solution.to_s.end_with?(test_value.to_s)
      concatination_eq = Equation.new(@solution.to_s.delete_suffix(test_value.to_s).to_i, new_test_values)

      possible_concatination && concatination_eq.valid?(with_concat: with_concat)
    end

    sig { returns(T::Boolean) }
    def base_case?
      @test_values.length == 2
    end
  end
end
