require_relative 'pool'

module Tabletop
  
  class Conditional
    attr_reader :outcomes, :conditions
    
    def initialize(outcomes, conditions)
      @outcomes = outcomes
      @conditions = conditions
    end
  end
    
  class Roll
    attr_reader :pool, :conditionals
    
    def initialize(pool=nil, &block)
      if pool
        raise ArgumentError if pool.class != Tabletop::Pool
      end
      @pool = pool
      @conditionals = []
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
      @conditionals.each do |cond|
        if meets?(cond)
          cond.outcomes.each do |outcome|
            if Roll === outcome
              results << outcome.roll
            else
              results << outcome
            end
          end
        end
      end
      if results.empty?
        results = [nil] 
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
      @pool.roll 
    end
    
    def meets?(c)
      answer = true
      if c.conditions[:>=]
        if c.conditions[:>=] > sum
          answer = false
        end
      end
      if c.conditions[:==]
        answer = false if c.conditions[:==] != sum
      end
      answer
    end
    
    def sum
      @pool.sum + @static_modifier + @roll_modifier
    end
    
    # instance_eval methods
    
    ## Conditional-creating methods
    def at_least(value, *outcomes)
      @conditionals << Conditional.new(outcomes, :>= => value)
    end
    
    def equals(values, *outcomes)
      if values.class == Range
        values.each do |val|
          @conditionals << Conditional.new(outcomes, :== => val)
        end
      else
        @conditionals << Conditional.new(outcomes, :== => values)
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
    def modifier(mod)
      @static_modifier = mod
    end
    
    def sides(num_sides)
      @die_sides = num_sides
    end
    
  end
  
end