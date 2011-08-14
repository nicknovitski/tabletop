# tabletop

Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.

Currently, you can create pools of dice, and rolls that compare them to different possible results.

## Installation

    gem install tabletop
    
    require 'tabletop'

## Dice

Dice are pretty straightforward.  They've got a number of sides, set on instantiation (defaulting to 6), and a current value between that number and 1 inclusive, which can be set on instantiation, or directly. They can be rolled, which gives them a new random value.

    d6 = Die.new
    d6.sides     #=> 6
    d6.value     #=> 4
    d6.roll
    d6.value     #=> 2
    
    d8 = Die.new(8, 4)
    d8.sides     #=> 8
    d8.to_s      #=> "[3]/d8"
    
One fun special kind of die is a "Fudge Die".  They are a special kind of three-sided die that have three possible values: -1, 0, or 1.  Those are usually expressed as '-', ' ' and '+', though. 

    f = FudgeDie.new
    f.sides      #=> 3
    f.value      #=> 0
    f.to_s       #=> "[ ]"

### Pools

Pools are essentially arrays of Dice objects with some extra helpful methods.

The _best_ way to create one is exactly the way you'd expect: the same old d-notation we've been using for decades.  You can even combine them with `+`.

    3.d6           #=> [[3]/d6, [3]/d6, [4]/d6]
    2.d10 + 1.d8   #=> [[2]/d10, [6]/d10, [8]/d8]
    
You can also create them by passing Pool.new a literal array of dice, or (slightly more interesting) a string in die notation.

The methods are common operations you might do on a pool of dice: summing, counting sets, dropping the lowest or highest valued dice, dropping all _but_ the lowest or highest valued dice, even dropping any dice  a specified list of values. 

    d&d = 3.d6.sum    #=> 13
    ore = 10.d10.sets #=> ["3x2", "2x8", "1x7", "1x6", "1x4", "1x3", "1x1"]
    cortex = (1.d8 + 2.d6).drop([1]).highest(2).sum  #=> 9
    tsoy = (4.dF).drop_lowest.sum  #=> 2

You can also #roll an entire pool, or you can interact with individual dice in the array using array indices (`[]`).
  
When pools are compared to each other or to numbers with <=>, it's assumed you're actually interested in their sum.  The same thing happens if you try to add a number to them.

    d&d_alt = 4.d4 + 4   #=> 17
    1.d20 > 2.d10        #=> false
    
### Rolls

Rolls are very much under construction, but they allow you to automate randomly determining results in a variety of ways.

Rolls have a lot of options.  Let's start by taking an example from one of my favorite games, Apocalypse World.

>When you open your brain to the world’s psychic maelstrom, roll+weird. On a hit, the MC will tell you something new and interesting about the current situation, and might ask you a question or two; answer them. On a 10+, the MC will give you good detail. On a 7–9, the MC will give you an impression.

(In the parlance of the game, a "hit" is getting a 7 or higher on 2d6, plus a stat.)

Here's how I'd write it out in Tabletop.

    cool = [-1, 0, 1, 2, 3].sample #=> get a random stat
    
    open_brain = Roll.new(2.d6) {
      modifier cool
      at_least 7, "the MC will tell you something new and interesting about the current situation"
      equals (7..9), "...but it's just an impression"
      at_least 10, "...and it's a good detail"
    }
    
Simple, right?  `add` sets a value to be permanently added for the purposes of determining results.  `at_least` and `equals` take an integer (or a range, in the case of `equals`) as their first parameter, and then one or more results to trigger if the pools result meets the stated condition.

Once they've been instantiated, Rolls have two important methods. 

#### #roll
 
This method which re-rolls all the dice in the pool, and returns the Roll object.  It can take an options hash as a parameter.  Notably, one of the options is `:modifier`, which sets a temporary modifier for that roll only; it's cleared the next time `roll` is called.
    
    bad_luck = -1
    open_brain.roll(:modifier => bad_luck)

#### #effects

This method returns an array, based on the current state of the pool, and any conditions and modifiers. Here's what I can tell you about the Array:

* Its first element is the "result" of the current pool, which is by default the sum of the values of its dice, plus any static or per-roll modifiers.
* The second and subsequent elements are the results of any satisfied conditions.
* If no conditions are satisfied, then the second and final element of the array is `nil`

So, possible results for our cool AW roll:

    open_brain.roll.effects #=> [4, nil]
    open_brain.roll.effects #=> [8, "the MC will tell you something new and interesting about the current situation", "...but it's just an impression"]
    roll, *effects = open_brain.roll.effects 
    puts roll               #=> 10 
    puts effects            #=> ["the MC will tell you something new and interesting about the current situation", "...and it's a good detail"]
    
Just these few functions already give enough functionality to do different kinds of rolls, but there's a lot more in store.

One last thing I'll briefly note is that Rolls can be nested. 

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
    fist_game.roll.effects   #=> [2, "JanKenPon", [1, "guu"]]

This can lead to some surprisingly sophisticated constructions.  Remember that "tables" are really just a special case of a roll!

## How to contribute

*First and most importantly*, any complaints or suggestions, *regardless of coding knowledge*, are *always welcome* at <nick.novitski@gmail.com>.

But, if you're feeling up to it, you can always do more.  You probably already know the drill by this point.

* Fork the project.
* Create a topic branch
* Make tests that describe your feature addition or bug fix.
* Write code that passes those tests
* Commit, without altering the version.
* Send me a pull request.

## Copyright

Copyright (c) 2011 Nick Novitski. See LICENSE for details.
