require_relative 'randomizers'

module Tabletop
  class Pool < Array
    include Comparable
    
    # requires one parameter, which can be either of 
    #  - an array of Die objects
    #  - a string of d-notation
    def initialize(init_dice)
      return super(init_dice) if init_dice.kind_of?(Array)
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
    
    # Behavior depends on the class of what is passed to it.
    # Numeric::  returns the sum of the operand and the values of all dice in the receiving pool
    # Pool:: returns a new pool with copies of all the dice in both operands
    # AnythingElse:: raises an ArgumentError
    def +(operand)
      # if the operator is a pool, or an array only of Die objects...
      if operand.instance_of?(Pool) or (operand.instance_of?(Array) and !(operand.detect{|obj| !(obj.instance_of?(Die))}))
        new_union(operand)
      elsif operand.kind_of? Numeric
        sum + operand
      else
        raise ArgumentError, "Cannot add operand of class #{operand.class}"
      end
    end
    
    #  Compares the operand to #sum  
    def <=>(operand)
        sum <=> operand.to_int
    end
      
    # Returns #sum times the operand
    def *(operand)
      sum * operand
    end
    
    def coerce(other) #:nodoc:
      [other, sum]
    end
    
    # Returns an array of the value of each die in the pool 
    def values
      map {|die| die.value}
    end
    
    # Returns a string of the pool's dice in d-notation 
    def dice
      fudge = nil
      result = {}
      each do |die|
        if die.instance_of?(FudgeDie)
          fudge = count {|d| d.instance_of?(FudgeDie)}
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
    
    # Rolls every die in the pool, and returns the Pool.
    def roll
      each do |die|
        die.roll
      end
      self
    end
    
    # Returns the sum of all values of dice in the pool
    def sum
      inject(0) {|sum, d| sum + d.value}
    end
    def to_int
      sum
    end
    
    # Returns a string describing all sets of die values in the pool in ORE notation.
    def sets
      result = {}
      each do |die|
        result[die.value] = count {|d| d.value == die.value}
      end
      result.sort_by{|height, width| [width, height] }.collect {|i| i[1].to_s+"x"+i[0].to_s}.reverse
    end
    
    # Returns a Pool containing copies of the n highest dice
    def highest(n=1)
      Pool.new(sort.reverse.first(n))
    end
    
    # Returns a Pool containing copies of the n lowest dice
    def lowest(n=1)
      Pool.new(sort.first(n))
    end
    
    # Returns a copy of the Pool, minus the n highest-value dice
    def drop_highest(n=1)
      Pool.new(self-highest(n))
    end
    
    # Returns a copy of the Pool, minus the n lowest-value dice.
    def drop_lowest(n=1)
      Pool.new(self-lowest(n))
    end
    
    # Returns a copy of the current pool, minus any 
    # dice with values equal the value (or in the array 
    # of values) passed. 
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
        if die.instance_of?(FudgeDie)
          new_pool << FudgeDie.new(die.value)
        else
          new_pool << Die.new(die.sides, die.value)
        end
      end
      Pool.new(new_pool)
    end
  end
end