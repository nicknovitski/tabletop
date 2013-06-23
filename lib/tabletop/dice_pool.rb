require 'forwardable'
require_relative 'randomizers'

module Tabletop
  class DicePool
    include Comparable
    attr_accessor :dice
    extend Forwardable   
    delegate [:size, :[], :count, :all?] => :@dice

    # Requires one parameter, which can be either of 
    #  - an array of Die objects
    #  - a string of elements separated by spaces which can be in two different formats:
    #     + d-notation (ie, "d20", "3dF", etc) denoting dice that will be given random values
    #     + a value, a slash, then a number of sides (ie, "2/6", "47/100", etc)
    def initialize(init_dice)
      if init_dice.kind_of?(DicePool)
        return init_dice
      elsif init_dice.kind_of?(Array)
        @dice = init_dice
      else
        d_groups = init_dice.split
        @dice = []
        d_groups.each do |d|
          if d =~ /d/ # d_notation
            number, sides = d.split('d')
            number = number.to_i
            number += 1 if number == 0
            if sides.to_i > 0
              number.times { @dice << Die.new(sides: sides.to_i)}
            elsif sides == "F"
              number.times { @dice << FudgeDie.new}
            end
          else
            @dice << Die.new_from_string(d)
          end
        end
      end
    end
    
    # If adding a pool or array of dice objects, returns the the union of these pools.
    #
    # If adding a number, returns the sum of that number and all die values in the pool.
    #
    # Otherwise, raises an ArgumentError.
    def +(operand)
      # if the parameter seems to be an array of dice (this includes pools)
      if operand.respond_to?(:dice) 
        new_union(operand.dice)
      # if the parameter seems to be a randomizer
      elsif operand.respond_to?(:randomize)
        new_union([operand])
      elsif operand.respond_to?(:to_int)
        sum + operand
      else
         raise ArgumentError, "Only numbers and other pools can be added to pools"
      end
    end

    def -(operand)
      begin 
        @dice - operand.dice
      rescue
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
      @dice.map {|die| die.value}
    end
    
    # Returns a string of the pool's dice in d-notation 
    def d_notation
      fudge = nil
      result = {}
      @dice.each do |die|
        if die.instance_of?(FudgeDie)
          fudge = @dice.count {|d| d.instance_of?(FudgeDie)}
        else
          result[die.sides] = @dice.count {|d| d.sides == die.sides}
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
    def roll(params={})
      @dice.each do |die|

        meets_all_conditions = true

        params.each do |condition, term|
          attribute, comparison = condition.to_s.split("_")
          die_att = die.send(attribute.to_sym)

          case comparison
          when "under"
            meets_all_conditions = false unless die_att < term
          when "over"
            meets_all_conditions = false unless die_att > term
          when "equals"
            meets_all_conditions = false unless die_att == term
          end
        end

        die.roll if meets_all_conditions
      end
      self
    end

    def roll_if(&block)
      @dice.each do |die|
        die.roll if block.call(die)
      end
    end
    
    # Returns the sum of all values of dice in the pool
    def sum
      @dice.inject(0) {|sum, d| sum + d.value}
    end
    def to_int
      sum
    end
    
    # Returns a string describing all sets of die values in the pool in ORE notation.
    def sets
      result = {}
      @dice.each do |die|
        result[die.value] = @dice.count {|d| d.value == die.value}
      end
      result.sort_by{|height, width| [width, height] }.collect {|i| i[1].to_s+"x"+i[0].to_s}.reverse
    end
    
    # Returns a Pool containing copies of the n highest dice
    def highest(n=1)
      if n < @dice.length
        drop_lowest(@dice.length-n)
      else
        self
      end
    end
    
    # Returns a Pool containing copies of the n lowest dice
    def lowest(n=1)
      sorted = @dice.sort.first(n)
      in_order = []
      @dice.each do |d|
        if sorted.include?(d)
          in_order << d
          sorted -= [d]
        end
      end
      self.class.new(in_order)
    end
    
    # Returns a copy of the Pool, minus the n highest-value dice
    def drop_highest(n=1)
      self.class.new(self-highest(n))
    end
    
    # Returns a copy of the Pool, minus the n lowest-value dice.
    def drop_lowest(n=1)
      self.class.new(self-lowest(n))
    end
    
    # Returns a copy of the current pool, minus any 
    # dice with values equal the value (or in the array 
    # of values) passed. 
    def drop(to_drop)
      to_drop = [to_drop].flatten #turn it into an array if it isn't one.
      kept = reject{|die| to_drop.include?{die.value}}
      self.class.new(kept)
    end
    
    private
    def new_union(array)
      union = [@dice, array].flatten # avoid using + in implementation of +
      new_pool =[]
      union.each do |die|
        new_pool << die.class.new(possible_values:die.possible_values, value:die.value)
      end
      DicePool.new(new_pool)
    end
  end
end
