require 'tabletop'

class Fixnum
  
  # Returns a pool of dice of the given sides and size self
  def dX(sides)
    dice = []
    times { dice << Tabletop::Die.new(sides) }
    Tabletop::Pool.new(dice)
  end
  
  # Returns a pool of fudge dice of size self
  def dF
    dice = []
    times {dice << Tabletop::FudgeDie.new}
    Tabletop::Pool.new(dice)
  end
  
  # Matches any methods of the form d(.*), and calls #dX($1.to_i)
  def method_missing(symbol, *args, &block)
    if symbol =~ /^d(.*)$/
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