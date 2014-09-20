require_relative 'randomizer'

module Tabletop
  class Die < Randomizer
    include Comparable

    # :sides must be greater than or equal to 2.  By default it is 6.
    # :value must be between 1 and :sides, inclusive.  By default it is random.
    def initialize(keywords={})
      sides = keywords.fetch(:sides) { 6 }.to_i
      raise ArgumentError, "invalid number of sides #{sides}" if sides < 2
      keywords[:possible_values] = keywords.fetch(:possible_values) { 1..sides }

      super(keywords)
    end

    def sides
      possible_values.length
    end

    def self.new_from_string(string)
      raise ArgumentError unless string.respond_to?(:split)
      v, s = string.split('/')
      Die.new(value: v.to_i, sides: s.to_i)
    end

    alias_method :roll, :randomize

    # Returns a string in the form "[#value]/d#sides"
    def to_s
      "[#{value}]/d#{sides}"
    end

    # Compares based on value of the die
    def <=>(operand)
      value <=> operand.to_int
    end

    # Returns the die's value
    def to_int
      value
    end

    private

    def new_with(val)
      self.class.new(sides: sides, value: val)
    end
  end
end
