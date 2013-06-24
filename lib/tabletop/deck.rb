module Tabletop
  class DrawMoreCardsThanDeckHasError < StandardError
  end

  class Deck < Hash
    def initialize
      super(0)
    end

    def << object
      if object.respond_to? :merge
        merge(object) {|card,ours,new| ours+new}
      else
        self[object] = 1
      end
    end

    def deck_size
      self.values.inject(:+)
    end

    def draw(cards=1)
      raise DrawMoreCardsThanDeckHasError if cards > self.deck_size
      drawable_cards = self.clone
      if block_given?
        drawable_cards = drawable_cards.keep_if {|card,copies| yield(card,copies) }
        return nil if drawable_cards.empty?
        # can't use select here, since that returns a Hash instead of a Deck
      end
      drawn = Deck.new
      cards.times do
        running_weight = 0
        n = rand*drawable_cards.deck_size
        drawable_cards.each do |card, weight|
          if running_weight < n && n <= running_weight + weight
            self[card] -= 1
            drawable_cards[card] -= 1
            drawn[card] += 1
          end
          running_weight += weight
        end
      end
      drawn
    end

    def possible_starting_hands(hand_size=7)

      # at any moment, there is some set of cards A that have the highest values, countA
      # (ie, there's the most of them in the deck)
      # there may also be some set of cards B that have the next-highest values, countB
      #
      # in the case of there only being As
        # the most likely combinations are equal numbers of each of them, or as close to that as possible.
        # if A.size is 1, and countA is greater than hand_size
          # the first and last combination would be {A1=>hand_size}
        # if A.size is 1, and countA is less than hand_size...
          # then raise an exception, of course
        # if A.size is 2, and countA is greater than hand_size
          # the first combination would be {A1=>hand}
        # if A.size is 2, and 2*countA is greater than hand_size
        # if A.size is 2, and 2*countA is less than hand_size, then again, exception
      #
      # So the first set of combinations has as it's left term
      # countA-countB of each card in A
      # and as it's right term,
      #
      # they are likely
      # n = copies of most popular card - copies of next most popular card
      #
      # first_hand = n copies of most popular card, up to seven
      # now there is some number A>=2 of cards that are equally likely
      # If A >= 7-n
      # first_hand << unique (k-n)-combinations of those A cards
      # if A < 7-n (that is, if )
      cards_uniq = self.keys
      Enumerator.new do |hands|

        counts = self.values.uniq.sort

        cards_uniq.repeated_combination(hand_size).each do |a|
          hands << a  if self.possible_hand?(a)
        end
      end
    end

    def possible_hand?(array)
      hand = Hash.new(0)
      array.each { |e| hand[e] +=1 }
      hand.each {|card, number| return false if (self[card].nil? or self[card] < number) }
      true
    end

    def chance_to_draw(cards)
      if Array === cards
        copy = self.clone
        odds = 1
        cards.each do |card|
          odds *= copy.chance_to_draw(card)
          copy[card] -= 1
        end
        odds
      else
        if self[cards] and self[cards] != 0
          Float(self[cards])/self.deck_size
        else
          0
        end
      end
    end
  end
end
