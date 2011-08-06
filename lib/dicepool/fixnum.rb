require 'dicepool'

class Fixnum
  def dX(sides)
    dice = []
    times do
      dice << DicePool::Die.new(sides)
    end
    DicePool::Pool.new(dice)
  end
  def method_missing(symbol, *args, &block)
    if symbol =~ /^d(.*)$/
      dX($1.to_i)
    else
      super
    end
  end
  def self.respond_to?(symbol, include_private = false)
    if method_sym.to_s =~ /^d(.*)$/
      true if $1.to_i >= 0
    else
      super
    end
  end
end