module Tabletop
  class Randomizer
    attr_reader :possible_values, :value

    def initialize(keywords = {})
      @possible_values = keywords.fetch(:possible_values) { [] }.to_a
      @value = keywords.fetch(:value) { random_value }
      check_value!
    end

    def valid_value?(val)
      possible_values.include?(val)
    end

    def set_to(new_val)
      check_value!(new_val)
      new_with(new_val)
    end

    def randomize
      set_to(random_value)
    end

    private

    def new_with(value)
      self.class.new(value: value)
    end

    def check_value!(val = @value)
      raise ArgumentError, "#{val} is not a valid value for #{self}" unless valid_value?(val)
    end


    def random_value
      possible_values.sample
    end
  end
end
