require 'spec_helper'
require 'shared_examples_for_randomizers'
require 'tabletop/randomizers'

module Tabletop
  RSpec.describe Randomizer do
    subject { Randomizer.new(:possible_values => 1..6) }
    it_behaves_like 'a randomizer'
  end
end
