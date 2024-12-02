# typed: strict

require 'sorbet-runtime'

module Day02
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      reports = input.map { |line| Report.new(line.split.map(&:to_i)) }
      reports.count(&:safe?)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      reports = input.map { |line| DampenedReport.new(line.split.map(&:to_i)) }
      reports.count(&:safe?)
    end
  end

  class Report
    extend T::Sig

    sig { params(input: T::Array[Integer]).void }
    def initialize(input)
      @levels = input
      @safe = T.let((all_increasing? || all_decreasing?) && close_levels?, T::Boolean)
    end

    sig { returns(T::Boolean) }
    def safe?
      @safe
    end

    private

    sig { returns(T::Boolean) }
    def all_increasing?
      @levels.each_cons(2).all? { |level1, level2| T.must(level1) < T.must(level2) }
    end

    sig { returns(T::Boolean) }
    def all_decreasing?
      @levels.each_cons(2).all? { |level1, level2| T.must(level1) > T.must(level2) }
    end

    sig { returns(T::Boolean) }
    def close_levels?
      @levels.each_cons(2).all? do |level1, level2|
        diff = (T.must(level1) - T.must(level2)).abs
        diff >= 1 && diff <= 3
      end
    end
  end

  class DampenedReport < Report
    sig { params(input: T::Array[Integer]).void }
    def initialize(input)
      super

      @safe = T.let(modified_reports.any?(&:safe?), T::Boolean)
    end

    private

    sig { returns(T::Array[Report]) }
    def modified_reports
      @levels.combination(@levels.length - 1).map do |new_levels|
        Report.new(new_levels)
      end
    end
  end
end
