# tabletop

Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.

## Installation

    gem install tabletop
    
    require 'tabletop'

## Dice

Dice are pretty straightforward.  They've got a number of sides, set on instantiation (defaulting to 6), and a current value between that number and 1 inclusive, which can be set on instantiation, or set directly. Finally, they can be rolled, which gives them a new random value.

    d6 = Die.new
    d6.sides     #=> 6
    d6.value     #=> 4
    d6.roll
    d6.value     #=> 2
    
    d8 = Die.new(8, 4)
    d8.sides     #=> 8
    d8.to_s      #=> "[4]/d8"
    
One fun special kind of die is a "Fudge Die".  They are a special kind of three-sided die that have three possible values: -1, 0, or 1.  Those are usually expressed as '-', ' ' and '+', though. 

    f = FudgeDie.new
    f.sides      #=> 3
    f.value      #=> 0
    f.to_s       #=> "[ ]"
    
You may not believe this, but coins are also a special case of die.  Coins have two sides, and have a value of either 1 or 0, aka heads or tails, aka "+" or " ".  They can be rolled if you really want, but you'd normally call that "flipping," right?

    c = Coin.new
    c.sides      #=> 2
    c.value      #=> 1
    c.to_s       #=> "(+)"
    c.flip.to_s  #=> "( )"  

### Pools

Pools are arrays of Dice objects with some extra helpful methods.

The _best_ way to create one is exactly the way you'd expect: the same old d-notation we've been using for decades.  You can even combine them with `+`.

    3.d6           #=> [[3]/d6, [3]/d6, [4]/d6]
    2.d10 + 1.d8   #=> [[2]/d10, [6]/d10, [8]/d8]

You can also create them by passing Pool.new a literal array of dice, or (slightly more interesting) a string in die notation.

Pool's instance methods are common operations you might do on a pool of dice: summing, counting sets, dropping the lowest or highest valued dice, dropping all _but_ the lowest or highest valued dice, even dropping any dice  a specified list of values. 

    d&d = 3.d6.sum    #=> 13
    ore = 10.d10.sets #=> ["3x2", "2x8", "1x7", "1x6", "1x4", "1x3", "1x1"]
    cortex = (1.d8 + 2.d6).drop([1]).highest(2).sum  #=> 9
    tsoy = (4.dF).drop_lowest.sum  #=> 2

You can also #roll an entire pool, or you can interact with individual dice in the array using array indices (`[]`).
  
When pools are compared to each other or to numbers with <=>, it's assumed you're actually interested in their sum.  The same thing happens if you try to add a number to them.

    4.d4 + 4         #=> 17
    1.d20 > 2.d10    #=> false
    
### Rolls

Rolls are very much under construction and their API is in flux, but they allow you to automate randomly determining results in a variety of ways.

Rolls have a lot of options, described in detail in the rubygems documentation.  But let's take a simple example from one of my favorite games, Apocalypse World.

>When you open your brain to the world’s psychic maelstrom, roll+weird. On a hit, the MC will tell you something new and interesting about the current situation, and might ask you a question or two; answer them. On a 10+, the MC will give you good detail. On a 7–9, the MC will give you an impression.

(In the parlance of the game, a "hit" is getting a 7 or higher.  "Roll+weird" means to roll 2d6 and add the character's "weird" stat, which is an integer from -1 to 3.)

Here's how I'd write that out in Tabletop:

    weird = [-1, 0, 1, 2, 3].sample #=> get a random stat
    
    open_brain = Roll.new(2.d6) {
      add weird
      at_least 7, "the MC will tell you something new and interesting about the current situation..."
      equals (7..9), "...but it's just an impression"
      at_least 10, "...and it's a good detail"
    }
    
Simple, right?  `add` sets a value to be permanently added for the purposes of determining results.  `at_least` and `equals` take an integer (or a range, in the case of `equals`) as their first parameter, and then one or more values to return if the pool's result meets the stated condition.

Once they've been instantiated, Rolls have three important methods. 

#### #roll
 
This method which re-rolls all the dice in the pool, and returns the Roll object.  It can take an options hash as a parameter.  Notably, one of the options is `:modifier`, which sets a temporary modifier for that roll only; it's cleared the next time `roll` is called.
    
    bad_luck = -1
    open_brain.roll(:modifier => bad_luck)

#### #result

This method, by default, returns the sum of the values of the Roll's dice, plus any static modifiers from `add` or per-roll modifiers from `roll(:modifier)`.

But!  When instantiating a roll, you can call `set_result` with an appropriate symbol to make `result` mean something else. 

For example, in Exalted, you principally care about how many dice in your pool came up 7 or higher, counting 10s twice:

    exalted = Roll.new(8.d10) do
      set_result :count, :at_least=>7, :doubles=>10
    end
    
    exalted.result   #=> 2
    exalted.sum      #=> 30

#### #effects

This method returns either an array containing the results passed to any `at_least` and `equals` calls whose conditions were met, or nil if no such conditions were met.

So, possible results for our cool AW roll:

    open_brain.roll.effects #=> nil
    open_brain.roll.effects #=> ["the MC will tell you something new and interesting about the current situation", "...but it's just an impression"]
    open_brain.roll 
    puts open_brain.result  #=> 10 
    puts open_brain.effects #=> ["the MC will tell you something new and interesting about the current situation", "...and it's a good detail"]
    
### Coming Soon

Just these few functions already give enough functionality to do different kinds of rolls, but there's a lot more in store.

One bonus thing I'll briefly note is that Rolls can be nested, and `effects` returns them as such. 

    rps = Roll.new(1.d3) {
      equals 1, "rock"
      equals 2, "paper"
      equals 3, "scissors"
    }
    jkp = Roll.new(1.d3) {
      equals 1, "guu"
      equals 2, "choki"
      equals 3, "paa"
    }
    fist_game = Roll.new(1.d2) {
      equals 1, "Rock Paper Scissors", rps
      equals 2, "JanKenPon", jkp 
    }
    fist_game.roll.effects   #=> ["JanKenPon", ["guu"]]

This can lead to some surprisingly sophisticated constructions.  Remember that "tables" are really just a special case of a roll!

## How to contribute

*First and most importantly*, if you're reading this and you make games, please tell me about them!  Second, any complaints or suggestions are always welcome, _regardless of coding knowledge_.  Feel free to communicate your opinions by creating an issue on the github project, or just drop me a line at <nick.novitski@gmail.com>.

If you have clear ideas about what more the project should do, and you think you can do something about it, then make it so!  Don't even bother asking me about it, you know the drill:

* Fork the project.
* Create a topic branch.
* Make tests that describe your feature addition or bug fix.
* Write code that passes those tests.
* Send me a pull request.

## Copyright

Copyright (c) 2011 Nick Novitski. See LICENSE for details.
