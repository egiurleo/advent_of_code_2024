# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day05
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      rules, solutions = rules_and_solutions(input)

      graph = Graph.new
      rules.each do |rule|
        node1, node2 = rule.split('|')
        raise if node1.nil? || node2.nil?

        graph.add(node1, node2)
      end

      solutions.map do |solution|
        graph.valid_solution?(solution) ? solution[solution.length / 2].to_i : 0
      end.sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: T::Array[String]).returns([T::Array[String], T::Array[T::Array[String]]]) }
    def rules_and_solutions(input)
      rules = T.let([], T::Array[String])
      solutions = T.let([], T::Array[T::Array[String]])

      parsing_solutions = T.let(false, T::Boolean)

      input.each do |line|
        if line == ''
          parsing_solutions = true
          next
        end

        parsing_solutions ? solutions << line.split(',') : rules << line
      end

      [rules, solutions]
    end
  end

  class Graph
    extend T::Sig

    sig { void }
    def initialize
      @nodes = T.let({}, T::Hash[String, Node])
      # mapping of nodes to all other nodes that must come before them
      @edges = T.let({}, T::Hash[Node, T::Array[Node]])
    end

    sig { params(node1_name: String, node2_name: String).void }
    def add(node1_name, node2_name)
      # node1 must come before node2

      node1 = node(node1_name)
      node2 = node(node2_name)

      existing_edges = @edges[node2] ||= []
      return if existing_edges.include?(node1)

      existing_edges << node1
    end

    sig { params(solution: T::Array[String]).returns(T::Boolean) }
    def valid_solution?(solution)
      solution_hash = solution.each_with_object({}) do |node_name, h|
        h[node_name] = true
      end

      valid_solution = solution.all? do |node_name|
        # binding.b if solution == %w[97 13 75 29 47]

        node = @nodes[node_name]
        return false if node.nil?

        node.visit
        edges = @edges[node] || []

        edges.empty? || edges.all? do |edge|
          edge.visited? || !solution_hash.key?(edge.name)
        end
      end

      reset_nodes
      valid_solution
    end

    private

    sig { void }
    def reset_nodes
      @nodes.each_value(&:unvisit)
    end

    sig { params(name: String).returns(Node) }
    def node(name)
      @nodes[name] ||= Node.new(name)
    end
  end

  class Node
    extend T::Sig

    sig { returns(String) }
    attr_reader :name

    sig { params(name: String).void }
    def initialize(name)
      @name = T.let(name, String)
      @visited = T.let(false, T::Boolean)
    end

    sig { returns(T::Boolean) }
    def visited?
      @visited
    end

    sig { void }
    def visit
      @visited = true
    end

    sig { void }
    def unvisit
      @visited = false
    end
  end
end
