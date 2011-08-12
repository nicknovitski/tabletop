require_relative 'die'
require 'delegate'

module Tabletop
  class Pool < DelegateClass(Array)
    include Comparable
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
    def +(operand)
      # if the operator is a pool, or an array only of Die objects...
      if operand.class == Pool or (operand.class == Array and !(operand.detect{|obj| obj.class != Die}))
        new_union(operand)
      elsif operand.kind_of? Numeric
        sum + operand
      else
        raise ArgumentError, "Cannot add operand of class #{operand.class}"
      end
    end
    
    def <=>(operand)
        sum <=> operand.to_int
    end
      
    def results
      map {|die| die.value}
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
      self
    end
    def sum
      inject(0) {|sum, d| sum + d.value}
    end
    def to_int
      sum
    end
    def sets
      result = {}
      each do |die|
        result[die.value] = count {|d| d.value == die.value}
      end
      result.sort_by{|height, width| [width, height] }.collect {|i| i[1].to_s+"x"+i[0].to_s}.reverse
    end
    def highest(n=1)
      Pool.new(sort.reverse.first(n))
    end
    def lowest(n=1)
      Pool.new(sort.first(n))
    end
    def drop_highest(n=1)
      Pool.new(self-highest(n))
    end
    def drop_lowest(n=1)
      Pool.new(self-lowest(n))
    end
    def drop(to_drop)
      to_drop = [to_drop].flatten #turn it into an array if it isn't one.
      kept = reject{|die| to_drop.any?{|drop_value| die.value == drop_value }}
      return Pool.new(kept)
    end
    
    private
    def new_union(array)
      union = [self, array].flatten
      new_pool =[]
      union.each do |die| 
        if die.class == FudgeDie
          new_pool << FudgeDie.new(die.value)
        else
          new_pool << Die.new(die.sides, die.value)
        end
      end
      Pool.new(new_pool)
    end
  end
end