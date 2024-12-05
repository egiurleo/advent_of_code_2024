# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day05
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      rules, solutions = rules_and_solutions(input)

      ruleset = RuleSet.new(rules)

      solutions.map do |solution|
        graph = SolutionGraph.new(solution, ruleset)
        graph.valid? ? graph.middle : 0
      end.sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end

    private

    sig { params(input: T::Array[String]).returns([T::Array[[Integer, Integer]], T::Array[T::Array[Integer]]]) }
    def rules_and_solutions(input)
      rules = T.let([], T::Array[[Integer, Integer]])
      solutions = T.let([], T::Array[T::Array[Integer]])

      parsing_solutions = T.let(false, T::Boolean)

      input.each do |line|
        if line == ''
          parsing_solutions = true
          next
        end

        parsing_solutions ? solutions << parse_solution(line) : rules << parse_rule(line)
      end

      [rules, solutions]
    end

    sig { params(input: String).returns(T::Array[Integer]) }
    def parse_solution(input)
      input.split(',').map(&:to_i)
    end

    sig { params(input: String).returns(Rule) }
    def parse_rule(input)
      n1, n2 = input.split('|').map(&:to_i)
      raise if n1.nil? || n2.nil?

      [n1, n2]
    end
  end

  Rule = T.type_alias { [Integer, Integer] }

  class RuleSet
    extend T::Sig

    sig { params(rules: T::Array[Rule]).void }
    def initialize(rules)
      @rules_hash = T.let({}, T::Hash[Rule, TrueClass])
      rules.each { |rule| @rules_hash[rule] = true }
    end

    sig { params(nodes: T::Array[Integer]).returns(T::Array[Rule]) }
    def rules_for(nodes)
      rules = []

      nodes.combination(2) do |node1, node2|
        raise if node1.nil? || node2.nil?

        if @rules_hash.key?([node1, node2])
          rules << [node1, node2]
        elsif @rules_hash.key?([node2, node1])
          rules << [node2, node1]
        end
      end

      rules
    end
  end

  class Node
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :name

    sig { params(name: Integer).void }
    def initialize(name)
      @name = T.let(name, Integer)
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

  class SolutionGraph
    extend T::Sig

    sig { params(solution: T::Array[Integer], ruleset: RuleSet).void }
    def initialize(solution, ruleset)
      @ruleset = T.let(ruleset.rules_for(solution), T::Array[Rule])
      @solution = T.let(solution, T::Array[Integer])
      @nodes = T.let({}, T::Hash[Integer, Node])
      # mapping of nodes to all other nodes that must come before them
      @edges = T.let({}, T::Hash[Node, T::Array[Node]])

      @ruleset.each do |rule|
        add(*rule)
      end

      @valid = T.let(nil, T.nilable(T::Boolean))
    end

    sig { returns(T::Boolean) }
    def valid?
      return @valid unless @valid.nil?

      @valid = @solution.all? do |node_name|
        node = @nodes[node_name]
        raise if node.nil?

        node.visit
        edges = @edges[node] || []

        edges.empty? || edges.all?(&:visited?)
      end
    end

    sig { returns(Integer) }
    def middle
      middle = @solution[@solution.length / 2]
      raise if middle.nil?

      middle
    end

    private

    sig { params(node1_name: Integer, node2_name: Integer).void }
    def add(node1_name, node2_name)
      # node1 must come before node2

      node1 = node(node1_name)
      node2 = node(node2_name)

      existing_edges = @edges[node2] ||= []
      return if existing_edges.include?(node1)

      existing_edges << node1
    end

    sig { params(name: Integer).returns(Node) }
    def node(name)
      @nodes[name] ||= Node.new(name)
    end
  end
end
