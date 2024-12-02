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

    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: T::Array[String]).returns(T::Array[Report]) }
    def process(input)
      input.map do |line|
        levels = line.split.map(&:to_i)
        Report.new(levels)
      end
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
