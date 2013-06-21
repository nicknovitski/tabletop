require 'tabletop'

class Fixnum
  
  # Returns a pool of dice of the given sides and size self
  def d(sides)
    Tabletop::DicePool.new("#{self}d#{sides}")
  end
  
  # Returns a pool of fudge dice of size self
  def dF
    Tabletop::DicePool.new("#{self}dF")
  end
  
  [4,6,8,10,12,20,30,66,100,666,1000,10000].each do |sides|
    define_method("d#{sides}") { self.d(sides) }
  end
end
