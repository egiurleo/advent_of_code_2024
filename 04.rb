# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day04
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      word = 'XMAS'

      deg0 = Matrix.new(input.map(&:chars))
      deg45 = deg0.rotate45
      deg90 = deg0.rotate90
      deg135 = deg90.rotate45
      deg180 = deg90.rotate90
      deg225 = deg180.rotate45
      deg360 = deg180.rotate90
      deg405 = deg360.rotate45

      directions = [deg0, deg45, deg90, deg135, deg180, deg225, deg360, deg405]

      directions.map { |dir| dir.count(word) }.reduce(0, &:+)

      # 3.times do
      #   count += matrix.count(word)
      #   count += matrix.rotate45.count(word)

      #   matrix = matrix.rotate90
      # end

      # count
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: T::Array[T::Array[String]]).returns(Integer) }
    def count(input)
      input.map(&:join).map do |line|
        line.scan('XMAS').size
      end.reduce(0, &:+)
    end
  end

  class Matrix
    extend T::Sig

    sig { params(input: T::Array[T::Array[String]]).void }
    def initialize(input)
      @input = T.let(input, T::Array[T::Array[String]])
    end

    sig { returns(Matrix) }
    def rotate90
      self.class.new(@input.transpose.map(&:reverse))
    end

    sig { returns(Matrix) }
    def rotate45
      rotated = Hash.new { |hash, key| hash[key] = [] }

      @input.each_with_index do |row, i|
        row.each_with_index do |val, j|
          rotated[i + j] << val
        end
      end

      self.class.new(rotated.values)
    end

    sig { returns(String) }
    def to_s
      @input.map(&:join).join("\n")
    end

    sig { params(word: String).returns(Integer) }
    def count(word)
      @input.map(&:join).map do |line|
        line.scan(word).size
      end.reduce(0, &:+)
    end
  end
end
