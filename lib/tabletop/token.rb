module Tabletop
  
  class NotEnoughTokensError < ArgumentError
    def initialize(wanted, available)
      w_t, a_t = "token", "token"
      
      w_t << "s" if wanted > 1 or wanted == 0
      
      a_t << "s" if available > 1 or available == 0
      
      available = available > 0 ? available : "no"
      
      super("tried to remove #{wanted} #{w_t} from a stack with #{available} #{a_t}")
    end
  end
  
  class ExceedMaxTokensError < ArgumentError
  end
  
  class TokenStack
    
    # The number of tokens in the stack, and the maximum number it can have
    attr_accessor :count, :max
    include Comparable
    
    def initialize(num_tokens = 1, hash={})
      @count = num_tokens
      @max = hash[:max]
    end
    
    def <=>(operand)
        count <=> operand.to_int
    end
    
    def count=(new_value)
      raise_if_over_max(new_value)
      @count = new_value
    end
    
    def add(n = 1)
      raise ArgumentError unless n.respond_to?(:to_i)
      raise ArgumentError if n < 0
      n = n.to_i
      raise_if_over_max(n + @count)
      @count += n
    end
    
    def raise_if_over_max(value)
      if @max
        raise ExceedMaxTokensError if value > @max
      end 
    end
    
    # Raises NotEnoughTokensError if there aren't enough tokens to remove 
    def remove(n=1)
      raise ArgumentError unless n.respond_to?(:to_i)
      n = n.to_i
      raise ArgumentError if n < 0
      if n > @count
        raise NotEnoughTokensError.new(n, @count)
      end
      @count -= n
    end
    
    # Usage: stack_a.move(N, :to => stack_b)
    # Removes N tokens from stack_a, and adds 
    # the same number to stack_b 
    def move(n, opts)
      begin
        opts[:to].add(n)
      rescue NoMethodError
        raise ArgumentError
      end
      
      begin
        remove(n)
      rescue NotEnoughTokensError
        opts[:to].remove(n)
        raise
      end
    end
    
    def refresh
      raise NoMethodError if @max.nil?
      @count = @max
    end
  end
end