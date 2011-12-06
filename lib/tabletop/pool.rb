require_relative 'randomizers'

module Tabletop
  class Pool < Array
    include Comparable
    
    # Requires one parameter, which can be either of 
    #  - an array of Die objects
    #  - a string of elements separated by spaces which can be in two different formats:
    #     + d-notation (ie, "d20", "3dF", etc) denoting dice that will be given random values
    #     + a value, a slash, then a number of sides (ie, "2/6", "47/100", etc)
    def initialize(init_dice)
      return super(init_dice) if init_dice.kind_of?(Array)
      d_groups = init_dice.split
      dice = []
      d_groups.each do |d|
        if d =~ /d/ # d_notation
          number, sides = d.split('d')
          number = number.to_i
          number += 1 if number == 0
          if sides.to_i > 0
            number.times { dice << Die.new(sides: sides.to_i)}
          elsif sides == "F"
            number.times {dice << FudgeDie.new}
          end
        else
          dice << Die.new_from_string(d)
        end
      end
      super(dice)
    end
    
    # If adding a pool or array of dice objects, returns the the union of these pools.
    #
    # If adding a number, returns the sum of that number and all die values in the pool.
    #
    # Otherwise, raises an ArgumentError.
    def +(operand)
      # if the parameter seems to be an array of dice (this includes pools)
      if operand.respond_to?(:all?) and operand.all?{|obj| obj.respond_to?(:roll)}
        new_union(operand)
      elsif operand.respond_to?(:to_int)
        sum + operand
      else
         raise ArgumentError, "Only numbers and other pools can be added to pools"
      end
    end

    def -(operand)
      if operand.respond_to?(:to_a)
        super
      else
        sum - operand
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
      if n < length
        drop_lowest(length-n)
      else
        self
      end
    end
    
    # Returns a Pool containing copies of the n lowest dice
    def lowest(n=1)
      sorted = sort.first(n)
      in_order = []
      each do |d|
        if sorted.include?(d)
          in_order << d
          sorted -= [d]
        end
      end
      Pool.new(in_order)
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
      Pool.new(kept)
    end
    
    private
    def new_union(array)
      union = [self, array].flatten
      new_pool =[]
      union.each do |die| 
        if die.instance_of?(FudgeDie)
          new_pool << FudgeDie.new(die.value)
        elsif die.instance_of?(Coin)
          new_pool << Coin.new(die.value)
        else
          new_pool << Die.new(sides: die.sides, value: die.value)
        end
      end
      Pool.new(new_pool)
    end
  end
end