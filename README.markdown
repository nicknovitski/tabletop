# tabletop

Tabletop aims to provide a simple way of describing, automating and tracking the tools and tasks involved in "analog" games, determining results from the motions and properties of various dice and chips.

Currently, you can roll dice with it.

## Installation

    gem install tabletop

## Usage

    require 'tabletop'

The easiest way to create a pool of dice is exactly the way you'd expect.

    3.d6
    2.d10 + 1.d8
    12.d17
    
Pools are arrays of Dice objects that have a few nice extra functions.

    d&d_strength = 3.d6.sum
    ore_character = 10.d10.sets
    cortex_result = (1.d8 + 2.d6 + 1.d4).highest(2).sum

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
