# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day01
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      list1, list2 = process(input)

      list1 = list1.sorted
      list2 = list2.sorted

      (0...list1.length).map { |idx| (list1.get(idx) - list2.get(idx)).abs }.reduce(:+)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      list1, list2 = process(input)

      (0...list1.length).map do |idx|
        val = list1.get(idx)
        count = list2.count(val)

        val * count
      end.reduce(:+)
    end

    private

    sig { params(input: T::Array[String]).returns([List, List]) }
    def process(input)
      list1 = T.let([], T::Array[Integer])
      list2 = T.let([], T::Array[Integer])

      input.each do |line|
        int1, int2 = line.split.map(&:to_i)
        list1 << T.must(int1)
        list2 << T.must(int2)
      end

      [List.new(list1), List.new(list2)]
    end
  end

  class List
    extend T::Sig

    sig { params(list: T::Array[Integer]).void }
    def initialize(list)
      @list = list
      @counts = T.let(
        list.each_with_object(Hash.new(0)) do |elem, h|
          h[elem] += 1
        end,
        T::Hash[Integer, Integer]
      )
    end

    sig { params(idx: Integer).returns(Integer) }
    def get(idx)
      val = @list[idx]

      raise StandardError if val.nil?

      val
    end

    sig { params(val: Integer).returns(Integer) }
    def count(val)
      @counts[val] || 0
    end

    sig { returns(Integer) }
    def length
      @list.length
    end

    sig { returns(List) }
    def sorted
      self.class.new(@list.sort)
    end
  end
end
