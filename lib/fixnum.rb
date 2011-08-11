require 'tabletop'

class Fixnum
  def dX(sides)
    dice = []
    times { dice << Tabletop::Die.new(sides) }
    Tabletop::Pool.new(dice)
  end
  def dF
    dice = []
    times {dice << Tabletop::FudgeDie.new}
    Tabletop::Pool.new(dice)
  end
  def method_missing(symbol, *args, &block)
    if symbol =~ /^d(.*)$/
      dX($1.to_i)
    else
      super
    end
  end
  def respond_to?(symbol, include_private = false)
    if symbol.to_s =~ /^d(.*)$/
      true if $1.to_i > 0
    else
      super
    end
  end
end