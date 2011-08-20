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
  
  class TokenStack
    
    # The number of tokens in the Stack
    attr_accessor :count
    include Comparable
    
    def initialize(num_tokens = 1)
      @count = num_tokens
    end
    
    def <=>(operand)
        count <=> operand.to_int
    end
    
    def add(n = 1)
      raise ArgumentError unless n.instance_of?(Fixnum) and n > 0
      @count += n
    end
    
    # Raises NotEnoughTokensError if there aren't enough tokens to remove 
    def remove(n=1)
      raise ArgumentError unless n.instance_of?(Fixnum) and n > 0
      if n > @count
        raise NotEnoughTokensError.new(n, @count)
      end
      @count -= n
    end
    
    # Removes N tokens from the receiver stack, then 
    # adds them to the stack in opts[:to] 
    def move(n, opts)
      raise(ArgumentError, "target is #{opts[:to].class}, not TokenStack") unless opts[:to].instance_of?(TokenStack)
      remove(n)
      opts[:to].add(n)
    end
  end
end