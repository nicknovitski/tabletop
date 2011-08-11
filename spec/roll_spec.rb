require 'spec_helper'

module Tabletop
  describe Roll do
    it "requires a pool" do
      Roll.new(2.d6)
      Roll.new(Pool.new("4d10 2d2"))
    end
  end
end