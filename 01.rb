# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day01
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      list1, list2 = process(input)
      list1.total_distance(list2)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      list1, list2 = process(input)
      list1.similarity_score(list2)
    end

    private

    sig { params(input: T::Array[String]).returns([SortedList, SortedList]) }
    def process(input)
      list1 = T.let([], T::Array[Integer])
      list2 = T.let([], T::Array[Integer])

      input.each do |line|
        int1, int2 = line.split.map(&:to_i)
        list1 << T.must(int1)
        list2 << T.must(int2)
      end

      [SortedList.new(list1), SortedList.new(list2)]
    end
  end

  class SortedList
    extend T::Sig

    sig { params(list: T::Array[Integer]).void }
    def initialize(list)
      @list = T.let(list.sort, T::Array[Integer])
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

    sig { params(other_list: SortedList).returns(Integer) }
    def total_distance(other_list)
      @list.map.with_index do |elem, idx|
        (elem - other_list.get(idx)).abs
      end.reduce(:+)
    end

    sig { params(other_list: SortedList).returns(Integer) }
    def similarity_score(other_list)
      @list.map do |elem|
        elem * other_list.count(elem)
      end.reduce(:+)
    end
  end
end
