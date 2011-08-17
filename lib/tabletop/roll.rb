require_relative 'pool'

module Tabletop
  
  class Possibility
    attr_reader :outcomes, :conditions
    
    def initialize(outcomes, conditions)
      @outcomes = outcomes
      @conditions = conditions
    end
  end
    
  class Roll
    attr_reader :pool, :possibilities
    
    def initialize(pool=nil, &block)
      if pool
        raise ArgumentError if pool.class != Tabletop::Pool
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
    
    def effects
      results = []
      
      if @difficulty
        results << "Success" if result >= @difficulty
      end
      
      @possibilities.each do |poss|
        if meets?(poss)
          poss.outcomes.each do |outcome|
            if outcome.instance_of?(Roll)
              results << outcome.roll.effects
            else
              results << outcome
            end
          end
        end
      end
      
          
      if results.empty?
        results << nil 
      end
      
      results.unshift(result)
    end
    
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
    
    def meets?(p)
      answer = true
      if p.conditions[:>=]
        if p.conditions[:>=] > sum
          answer = false
        end
      end
      if p.conditions[:==]
        answer = false if p.conditions[:==] != sum
      end
      answer
    end
    
    def sum
      @pool.sum + @static_modifier + @roll_modifier
    end
    
    # instance_eval methods
    
    ## Possibility-creating methods
    def at_least(value, *outcomes)
      @possibilities << Possibility.new(outcomes, :>= => value)
    end
    
    def equals(values, *outcomes)
      if values.instance_of?(Range)
        values.each do |val|
          @possibilities << Possibility.new(outcomes, :== => val)
        end
      else
        @possibilities << Possibility.new(outcomes, :== => values)
      end
    end
    
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
    
    # instance-variable-setting methods
    def add(mod)
      @static_modifier = mod
    end
    
    def sides(num_sides)
      @die_sides = num_sides
    end
    
  end
  
end