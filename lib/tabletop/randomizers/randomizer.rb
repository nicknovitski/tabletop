module Tabletop
  class Randomizer
    def initialize(keywords = {})
      @possible_values = keywords.fetch(:possible_values) { [] }.to_a
      self.value = keywords.fetch(:value) { random_value }
    end

    def random_value
      possible_values.sample
    end

    attr_reader :possible_values

    def valid_value?(val)
      possible_values.include?(val)
    end

    attr_reader :value

    def value=(val)
      raise ArgumentError, 'must be a valid value' unless valid_value?(val)
      @value = val
    end

    def set_to(new_val)
      self.value = new_val
      self
    end

    def randomize
      set_to(random_value)
    end
  end

end
