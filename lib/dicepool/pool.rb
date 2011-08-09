require_relative 'die'
require 'delegate'

module DicePool
  class Pool < DelegateClass(Array)
    def initialize(init_dice)
      return super(init_dice) if init_dice.class == Array
      d_groups = init_dice.split
      dice = []
      d_groups.each do |d_notation|
        number, sides = d_notation.split('d')
        number = number.to_i
        number += 1 if number == 0
        if sides.to_i > 0
          number.times { dice << Die.new(sides.to_i)}
        elsif sides == "F"
          number.times {dice << FudgeDie.new}
        end
      end
      super(dice)
    end
    def +(operator)
      # if the operator is a pool, or an array only of Die objects...
      if operator.class == Pool or (operator.class == Array and !(operator.detect{|obj| obj.class != DicePool::Die}))
        new_union(operator)
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
      fudge = nil
      result = {}
      each do |die|
        if die.class == FudgeDie
          fudge = count {|d| d.class == FudgeDie}
        else
          result[die.sides] = count {|d| d.sides == die.sides}
        end
      end
      d_array = result.sort.collect do |d_group| 
        number = d_group[1]
        number = "" if number == 1
        sides = d_group[0]
        "#{number}d#{sides}"
      end
      if fudge
        d_array << "#{fudge}dF"
      end
      d_array
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
    def to_int
      sum
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
    def drop(to_drop)
      to_drop = [to_drop].flatten #turn it into an array if it isn't one.
      kept = reject{|die| to_drop.any?{|drop_value| die.result == drop_value }}
      return Pool.new(kept)
    end
    
    private
    def new_union(array)
      union = [self, array].flatten
      new_pool =[]
      union.each do |die| 
        if die.class == FudgeDie
          new_pool << FudgeDie.new(die.result)
        else
          new_pool << Die.new(die.sides, die.result)
        end
      end
      Pool.new(new_pool)
    end
  end
end