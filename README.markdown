# tabletop

Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.

Currently, you can roll dice with it.

## Installation

    gem install tabletop

## Usage

Just `require 'tabletop'` and off you go!  The easiest way to create a pool of dice is exactly the way you'd expect.

    3.d6           #=> [3 (d6), 3 (d6), 4 (d6)]
    2.d10 + 1.d8   #=> [2 (d10), 6 (d10), 8 (d8)]
    6.d17          #=> [8 (d17), 3 (d17), 7 (d17), 16 (d17), 11 (d17), 10 (d17)]
    
Pools are arrays of Dice objects that have a few nice extra functions.

    d&d_strength = 3.d6.roll.sum #=> 13
    ore_character = 10.d10.sets #=> ["3x2", "2x8", "1x7", "1x6", "1x4", "1x3", "1x1"]
    cortex_result = (1.d8 + 2.d6 + 1.d4).highest(2).sum  #=> 9
    
Dice are pretty straightforward.

    d = Die.new
    d.sides     #=> 6
    d.result    #=> 4
    d.roll      #=> "2 (d6)"

## Note on Patches/Pull Requests
 
* Fork the project.
* Create a topic branch
* Make tests that describe your feature addition or bug fix.
* Write code that passes those tests
* Commit, without altering the rakefile or version.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request.

## Copyright

Copyright (c) 2011 Nick Novitski. See LICENSE for details.
