require 'spec_helper'


module Tabletop
  describe Deck do
    let(:d) do
      deck = Deck.new
      deck["Forest"] = 8
      deck["Mountain"] = 3
      deck["Island"] = 3
      deck["Rootbound Crag"] = 4
      deck["Hinterland Harbor"] = 4
      deck["Llanowar Elves"] = 3
      deck["Birds of Paradise"] = 4
      deck["Phantasmal Image"] = 4
      deck["Viridian Emissary"] = 4
      deck["Phyrexian Metamorph"] = 4
      deck["Acidic Slime"] = 4
      deck["Inferno Titan"] = 4
      deck["Wurmcoil Engine"] = 4
      deck["Rampant Growth"] = 4
      deck["Lead the Stampede"] = 3
      deck
    end
    it "defaults to having zero of things" do
      subject["Random Object"].should == 0
    end
    describe "#deck_size" do
        it "counts all the cards" do
          d.deck_size.should == 60
        end
      end
      describe "<<" do
        it "merges, summing together the values of collisions" do
          deck_a = Deck.new()
          deck_a["card A"] =1
          deck_a["card B"] = 1
          deck_b = Deck.new()
          deck_b["card B"] =2
          deck_b["card C"] =2
          merged_deck = deck_a.merge(deck_b) {|k,o,n| o+n}
          (deck_a << deck_b).should == merged_deck
        end
      end
      describe "#draw" do
        it "returns a deck containing a random card and decrements that card's copy count in the calling object" do
          srand(1841922)
          d.draw.should == {"Acidic Slime"=>1}
          d["Acidic Slime"].should == 3
        end
        context "with one parameter" do
          it "returns that many cards" do
            d.draw(3).length.should == 3
          end
          it "raises an exception when you try to draw too many" do
            expect {d.draw(61)}.to raise_error DrawMoreCardsThanDeckHasError
          end
        end
        context "when passed a block " do
          it "returns a random card for which the block returns true" do
            srand(1841922)
            d.draw {|card, copies| true}.should == {"Acidic Slime"=>1}
            srand(1841922)
            d.draw do |card, copies|
              card == "Forest" or card == "Island" or card == "Mountain"
            end.should == {"Mountain"=> 1}
          end
          it "returns nil if the card is not present" do
            srand(1841922)
            d.draw {|card, copies| false}.should be_nil
            d.draw do |card, copies|
              card == "Sir Not Appearing in this Test"
            end.should be_nil
          end
        end
      end
      describe "#chance_to_draw" do
        context "when passed a card" do
          it "returns the odds of drawing that card from the deck" do
            size = d.deck_size
            d.each do |card,copies|
              d.chance_to_draw(card).should == Float(copies)/size
            end
            d.chance_to_draw("A Card it Doesn't Have").should == 0
          end
        end
        context "when passed an array of cards" do
          it "returns the odds of drawing all the cards in the array from a draw of {array.length} cards" do
            d.chance_to_draw(["Acidic Slime"]).should == d.chance_to_draw("Acidic Slime")
            d.chance_to_draw(["Acidic Slime", "Phyrexian Metamorph"]).should == Float(4*4)/(60*59)
          end
        end
    end
    describe "#possible_starting_hands" do
      def factorial(number)
        (1..number).inject(:*)
      end
      def combinations(n,k)
        factorial(n) / (factorial(k) * factorial(n-k))
      end
      def check_psh(deck, hand_size)
        number_of_unique_cards = deck.length
        guess_hands = combinations(hand_size+number_of_unique_cards-1, hand_size)
        # Important note: the following only calculates combinations which have too many of any single card
        # for a hand of size N, there are some combinations of K cards (c1, c2, ... ck) which are impossible
        # how many integers between 2 and N are there which add to N?
        # make a recursive function for that, tail case
        # answer << [self]
        # if == 2, return 1, 1
        # then return (1..self-1).each {|v| add_up_to(self-v).each {|w| [v,w]}}
        unless hand_size == 1
          deck.each do |card, copies|
            if copies == hand_size-1
              guess_hands -= 1 #there is only one impossible hand in that case: a full hand of the card in question
            elsif copies < hand_size    # that is, if more copies of the card than exist might be in a possible hand
              guess_hands -= combinations(hand_size - (copies+1) + number_of_unique_cards - 1,
                                          hand_size - (copies+1))
            end
          end
        end

        if hand_size == 7
          deck.possible_starting_hands.to_a.length.should == guess_hands
        else
          deck.possible_starting_hands(hand_size).to_a.length.should == guess_hands
        end
      end
      it "enumerates all possible hand of a passed size (default 7)" do
        7.downto(1).each do |hand|
          check_psh(d, hand)
        end
        deck = Deck.new
        deck["card a"] = 20
        deck["card b"] = 20
        thing = []
        deck.possible_starting_hands.each do |hand|
          thing << [-1*deck.chance_to_draw(hand), hand]
        end
        p thing.sort
      end
      it "enumerates in descending order of likelihood" do
        pending "discovery of the algorithm"
        best_odds = 1
        deck = Deck.new
        deck["card a"] = 20
        deck["card b"] = 20
        deck.possible_starting_hands.each do |hand|
          chance = deck.chance_to_draw(hand)
          chance.should <= best_odds
          best_odds = chance
        end
      end
    end
  end
end