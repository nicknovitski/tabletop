require 'dicepool'
require 'delegate'

module DicePool
  class Pool < DelegateClass(Array)
    def initialize(init_dice)
      return super(init_dice) if init_dice.class == Array
      d_groups = init_dice.split
      dice = []
      d_groups.each do |d_notation|
        number, sides = d_notation.split('d')
        number, sides = number.to_i, sides.to_i
        number += 1 if number == 0
        number.times { dice << Die.new(sides)}
      end
      super(dice)
    end
    def +(operator)
      if operator.class == Pool 
        Pool.new([self, operator].flatten)
      elsif operator.kind_of? Numeric
        sum + operator
      else
        raise ArgumentError, "Cannot add operator of class #{operator.class}"
      end
    end
    def results
      map {|die| die.result}
    end
    def dice
      result = {}
      each do |die|
        result[die.sides] = count {|d| d.sides == die.sides}
      end
      result.sort.collect do |d_group| 
        number = d_group[1]
        number = "" if number == 1
        sides = d_group[0]
        "#{number}d#{sides}"
      end
    end
    def roll
      each do |die|
        die.roll
      end
      results
    end
    def sum
      inject(0) {|sum, d| sum + d.result}
    end
    def sets
      result = {}
      each do |die|
        result[die.result] = count {|d| d.result == die.result}
      end
      result.sort_by{|height, width| [width, height] }.collect {|i| i[1].to_s+"x"+i[0].to_s}.reverse
    end
    def highest(n=1)
      sorted = sort_by {|d| d.result}.reverse
      Pool.new(sorted.first(n))
    end
    def lowest(n=1)
      sorted = sort_by {|d| d.result}
      Pool.new(sorted.first(n))
    end
    def drop_highest(n=1)
      Pool.new(self-highest(n))
    end
    def drop_lowest(n=1)
      Pool.new(self-lowest(n))
    end
  end
end