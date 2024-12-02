# typed: strict

require 'sorbet-runtime'

module Day02
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      reports = process(input)
      reports.count(&:safe?)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      reports = process(input, problem_dampener: true)
      reports.count(&:safe?)
    end

    private

    sig { params(input: T::Array[String], problem_dampener: T::Boolean).returns(T::Array[Report]) }
    def process(input, problem_dampener: false)
      input.map do |line|
        levels = line.split.map(&:to_i)
        Report.new(levels, problem_dampener: problem_dampener)
      end
    end
  end

  class Report
    extend T::Sig

    sig { params(input: T::Array[Integer], problem_dampener: T::Boolean).void }
    def initialize(input, problem_dampener: false)
      @levels = input

      if problem_dampener
        modified_reports = []

        (0...@levels.length).each do |idx|
          new_levels = @levels.dup
          new_levels.delete_at(idx)

          modified_reports << Report.new(new_levels)
        end

        @safe = T.let(modified_reports.any?(&:safe?), T::Boolean)
      else
        @safe = T.let((all_increasing? || all_decreasing?) && close_levels?, T::Boolean)
      end
    end

    sig { returns(T::Boolean) }
    def safe?
      @safe
    end

    private

    sig { returns(T::Boolean) }
    def all_increasing?
      @levels.sort == @levels
    end

    sig { returns(T::Boolean) }
    def all_decreasing?
      @levels.sort.reverse == @levels
    end

    sig { returns(T::Boolean) }
    def close_levels?
      @levels.each_cons(2).all? do |level1, level2|
        next if level1.nil? || level2.nil?

        diff = (level1 - level2).abs
        diff >= 1 && diff <= 3
      end
    end
  end
end
