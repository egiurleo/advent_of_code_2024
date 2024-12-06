# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day06
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      map = Map.new(input.map(&:chars))
      map.guard_route
      map.visited_locations.size
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end
  end

  Location = T.type_alias { [Integer, Integer] }

  class Map
    extend T::Sig

    EMPTY = T.let('.'.freeze, String)
    BLOCKED = T.let('#'.freeze, String)

    class Direction < T::Enum
      extend T::Sig

      enums do
        Up = new('^')
        Right = new('>')
        Down = new('v')
        Left = new('<')
      end

      sig { returns(Direction) }
      def turn_right
        case self
        when Up then Right
        when Right then Down
        when Down then Left
        when Left then Up
        end
      end

      sig { params(curr_location: Location).returns(Location) }
      def next_location(curr_location)
        y, x = curr_location

        case self
        when Up
          [y - 1, x]
        when Right
          [y, x + 1]
        when Down
          [y + 1, x]
        when Left
          [y, x - 1]
        end
      end
    end

    sig { params(grid_array: T::Array[T::Array[String]]).void }
    def initialize(grid_array)
      raise if grid_array.empty? || grid_array.first&.empty?

      @grid = T.let({}, T::Hash[Location, String])

      @height = T.let(grid_array.length, Integer) # y
      @width = T.let(T.must(grid_array.first).length, Integer) # x

      # Location is specified y, x
      @guard_location = T.let([0, 0], Location)
      @guard_direction = T.let(Direction::Up, Direction)

      @visited_locations = T.let(Hash.new(false), T::Hash[Location, T::Boolean])

      initialize_grid(grid_array)
    end

    sig { void }
    def guard_route
      y, x = @guard_location

      while y < @height && y >= 0 && x >= 0 && x < @width
        @visited_locations[@guard_location] = true
        move_guard
        y, x = @guard_location
      end
    end

    sig { returns(T::Array[Location]) }
    def visited_locations
      @visited_locations.keys
    end

    sig { returns(String) }
    def to_s
      (0...@height).map do |i|
        (0...@width).map do |j|
          @guard_location == [i, j] ? @guard_direction.serialize : @grid[[i, j]]
        end.join
      end.join("\n")
    end

    sig { returns(String) }
    def readable_guard_location
      "[#{@guard_location[0]}, #{@guard_location[1]}]"
    end

    private

    sig { void }
    def move_guard
      next_location = @guard_direction.next_location(@guard_location)

      while blocked?(next_location)
        @guard_direction = @guard_direction.turn_right
        next_location = @guard_direction.next_location(@guard_location)
      end

      @guard_location = next_location
    end

    sig { params(location: Location).returns(T::Boolean) }
    def blocked?(location)
      @grid[location] == BLOCKED
    end

    sig { params(grid_array: T::Array[T::Array[String]]).void }
    def initialize_grid(grid_array)
      grid_array.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          case elem
          when EMPTY, BLOCKED
            @grid[[i, j]] = elem
          when *Direction.values.map(&:serialize)
            @grid[[i, j]] = '.'
            @guard_location = [i, j]
            @guard_direction = Direction.deserialize(elem)
          end
        end
      end
    end
  end
end
