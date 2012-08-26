require_relative 'dice_pool'

module Tabletop
  
  class Possibility #:nodoc: all
    attr_reader :outcomes
    
    attr_reader :conditions

    def initialize(outcomes, conditions)
      @outcomes, @conditions = outcomes, conditions
    end
    
  end
    
  class Roll
    # Rolls of necessity have a Pool object against which they check possible results.
    attr_accessor :pool
    

    # The block contains methods that further detail the roll, as described below.  
    # pool must be (surprise!) a Pool.  It's optional, because if #sides is passed 
    # in the block, then #roll can be called with a number of dice to roll, and a 
    # new Pool object will be instantiated every time this is done. 
    def initialize(pool=nil, &block)
      if pool
        raise ArgumentError if !pool.respond_to?(:roll)
      end
      @pool = pool
      @possibilities = []
      @die_sides = nil
      @static_modifier = 0
      @roll_modifier = 0
      @result_set = false
      instance_eval(&block)
      unless @result_set
        set_result(:sum)
      end
    end
    
    
    # Returns either an array or nil.
    # + If a "difficulty" was set in the most recent call of #roll, and #result meets or exceeds it, then the first element will be "Success". 
    # + If the conditions of any of the roll's @possibilities are met (see #meets?), then their outcomes will be all following elements. 
    # + If none of these conditions are met, returns nil
    def effects
      results = []
      
      if @difficulty
        results << "Success" if result >= @difficulty
      end
      
      @possibilities.each do |poss|
        results.concat(check(poss))
      end
      
      results.compact!

      if results.empty?
        results = nil
      end
      results
    end
    
    # Without any options passed, calls Pool#roll on the roll's pool.  Returns the Roll.
    # 
    # opts can have a few different values:
    # :modifier:: adds to all subsequent calls to #sum, until #roll is called again
    # :pool:: if #sides was called in the initialize block, and this is set, then a Pool of appropriate sides and number is created and assigned to @pool.
    # :difficulty:: see #effects 
    #--
    # TODO: @difficulty changes back to nil if it is not called in a given roll.
    # TODO: abstract out ternary?
    def roll(opts={})
      @roll_modifier = opts[:modifier] ? opts[:modifier] : 0
      if @die_sides
        if opts[:pool] 
          @pool = opts[:pool].dX(@die_sides)
        else
          raise ArgumentError
        end
      end
      if opts[:difficulty]
        @difficulty = opts[:difficulty]
      end
      @pool.roll
      self 
    end
    
    # Takes a Possibility, returns an Array containing nil if any of it's conditions
    # aren't met. Otherwise, returns an Array containing all the Possibility's
    # outcomes.  If any of those outcomes are Roll objects, they are rolled and their
    # #effects are returned as an outcome.
    #--
    # TODO: checks #result, not #sum
    def check(p) #:nodoc:
      conditions_met = true
      
      if p.conditions[:>=] and sum < p.conditions[:>=]
        conditions_met = false
      end
      
      if p.conditions[:==] and p.conditions[:==] != sum
        conditions_met = false
      end
      
      if conditions_met
        results = []
        p.outcomes.each do |outcome|
          if outcome.instance_of?(Roll)
            results << outcome.roll.effects
          else
            results << outcome
          end
        end
        results
      else
        [nil]
      end
    end
    
    # The sum of the values of dice in the pool, and any modifier set in 
    # instantiation (see #add), or the most recent call to #roll.
    def sum
      @pool.sum + @static_modifier + @roll_modifier
    end
    
    # Attaches an object to work with #meets?.
    # 
    # value:: An integer.
    # outcomes:: An array of values to contribute to #effects if #meets? is true.
    def at_least(value, *outcomes)
      @possibilities << Possibility.new(outcomes, :>= => value)
    end
    
    # Attaches an object to work with #meets?.
    #
    # values:: Can be either an integer, or a Range.  If it's a range, then #equals creates an object for each number in the range.  If it's an integer, it creates just one. 
    # outcomes:: An array of values to contribute to #effects if #meets? is true.
    #--
    # TODO: values can be an array
    def equals(values, *outcomes)
      if values.instance_of?(Range)
        values.each do |val|
          @possibilities << Possibility.new(outcomes, :== => val)
        end
      else
        @possibilities << Possibility.new(outcomes, :== => values)
      end
    end
    
    # Defines a #result method, used by #effects.
    # 
    # If symbol is ':count', then args must include a :at_least option, and #result will
    # be equal to the number of dice in @pool of value equal or greater than 
    # args[:at_least]. 
    # 
    # Optionally, args can also include a :doubles option, for values that add 2 to #result
    # 
    # In all other cases, #result is aliased to #sum
    # 
    # Meant to be used in the initialize block.
    #--
    # TODO: raise an error symbol is :count but :at_least is not set
    def set_result(symbol, args={})
      if symbol == :count
        @count_at_least = args[:at_least]
        @count_doubles = args[:doubles]
        def result
          normal = @pool.count {|die| die.value >= @count_at_least}
          extra = @count_doubles ? @pool.count {|die| die.value == @count_doubles} : 0
          normal + extra
        end
      else
        def result
          sum
        end
      end
      @result_set = true
    end
    
    # Sets a modifier that's added to #sum.  
    #
    # Meant to be used in the initialize block.
    def add(mod)
      @static_modifier = mod
    end
    
    # Sets a default die size.  If set, roll can be called with a :pool argument to 
    # create and roll a new Pool of the indicated number and type of dice.
    #
    # Can be an integer other than zero, or :fudge for fudgedice.
    #
    # Meant to be used in the initialize block.
    def sides(num_sides)
      @die_sides = num_sides
    end
    
  end
  
end