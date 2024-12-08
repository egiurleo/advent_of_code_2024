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
      new_solution = T.let(
        ->(t) { @solution - t },
        T.proc.params(test_value: Integer).returns(Integer)
      )

      safety_condition = T.let(
        ->(_) { true },
        T.proc.params(test_value: Integer).returns(T::Boolean)
      )

      sub_equation(new_solution, safety_condition)
    end

    sig { returns(Equation) }
    def multiplication_eq
      new_solution = T.let(
        ->(t) { @solution / t },
        T.proc.params(test_value: Integer).returns(Integer)
      )

      safety_condition = T.let(
        ->(t) { (@solution % t).zero? },
        T.proc.params(test_value: Integer).returns(T::Boolean)
      )

      sub_equation(new_solution, safety_condition)
    end

    sig { returns(Equation) }
    def concatination_eq
      new_solution = T.let(
        ->(t) { @solution.to_s.delete_suffix(t.to_s).to_i },
        T.proc.params(test_value: Integer).returns(Integer)
      )

      safety_condition = T.let(
        ->(t) { @solution.to_s.end_with?(t.to_s) },
        T.proc.params(test_value: Integer).returns(T::Boolean)
      )

      sub_equation(new_solution, safety_condition)
    end

    sig do
      params(new_solution: T.proc.params(test_value: Integer).returns(Integer),
             safety_condition: T.proc.params(test_value: Integer).returns(T::Boolean)).returns(Equation)
    end
    def sub_equation(new_solution, safety_condition)
      new_test_values = @test_values.dup
      test_value = new_test_values.pop

      raise if test_value.nil?
      return InvalidEquation.create unless safety_condition.call(test_value)

      Equation.new(new_solution.call(test_value), new_test_values, check_concat: @check_concat)
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
