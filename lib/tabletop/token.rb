module Tabletop
  
  class NotEnoughTokensError < ArgumentError
  end
  
  class TokenStack
    attr_accessor :count
    
    def initialize(n = 1)
      @count = n
    end
    
    def add(n = 1)
      raise ArgumentError unless Fixnum === n and n > 0
      @count += n
    end
    
    def remove(n=1)
      raise ArgumentError unless Fixnum === n and n > 0
      if n > @count
        n_t, c_t = "token", "token"
        
        n_t << "s" if n > 1 or n == 0
        
        c_t << "s" if @count > 1 or @count == 0
        
        c = @count > 0 ? @count : "no" 
        errmsg = "tried to remove #{n} #{n_t} from a stack with #{c} #{c_t}"
        raise NotEnoughTokensError, errmsg
      end
      @count -= n
    end
    
    def move(n, opts)
      raise(ArgumentError, "target is #{opts[:to].class}, not TokenStack") unless TokenStack === opts[:to]
      remove(n)
      opts[:to].add(n)
    end
  end
  

end