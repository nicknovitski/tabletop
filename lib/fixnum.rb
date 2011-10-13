require 'tabletop'

class Fixnum
  
  # Returns a pool of dice of the given sides and size self
  def dX(sides)
    Tabletop::Pool.new("#{self}d#{sides}")
  end
  
  # Returns a pool of fudge dice of size self
  def dF
    Tabletop::Pool.new("#{self}dF")
  end
  
  # Matches any methods of the form dN, where N > 0, and calls #dX(N)
  def method_missing(symbol, *args, &block)
    if symbol =~ /^d(.*)$/ and $1.to_i > 0
      dX($1.to_i)
    else
      super
    end
  end
  
  # Returns true for :dN, where N.to_i is a number > 0
  def respond_to?(symbol, include_private = false)
    if symbol.to_s =~ /^d(.*)$/
      true if $1.to_i > 0
    else
      super
    end
  end
end