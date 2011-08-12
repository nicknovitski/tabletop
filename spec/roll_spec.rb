require 'spec_helper'

module Tabletop
  describe Roll do
    
    describe "#pool" do
      it "accceses the roll's pool" do
        d20 = Roll.new(1.d20) do
        end
        d20.pool.class.should == Pool
        d20.pool.length.should == 1
        d20.pool[0].sides.should == 20
      end
    end
    
    context "use it like an attribute or skill roll" do
      
      context "Apocalypse World" do
        it "can be used with a static difficulty and dice pool, and both static and dynamic modifiers" do
          cool = 1
          under_fire = Roll.new(2.d6) do
            modifier cool
            at_least 10, "You do it"
            equals (7..9), "You flinch, hesitate, or stall"
          end
          20.times do 
            mod = [1, 0, -1].sample
            if mod != 0
              under_fire.roll(:modifier => mod)
            else
              under_fire.roll
            end
            if under_fire.pool.sum + cool + mod >= 10
              effect = "You do it"
            elsif under_fire.pool.sum + cool + mod >= 7
              effect = "You flinch, hesitate, or stall"
            end
            under_fire.effects.should == [under_fire.pool.sum + cool + mod, effect]
          end
        end
      end
      
      context "Exalted" do
        before :each do
          @exalted = Roll.new do
            set_result :count, :at_least=>7, :doubles=>10
            sides 10
          end
        end
        it "can be instantiated without a complete pool" do
          @exalted.roll(:pool=>6)
          @exalted.pool.length.should == 6
          @exalted.pool.each do |die|
            die.sides.should == 10
          end
          @exalted.roll(:pool=>10)
          @exalted.pool.length.should == 10
          lambda {@exalted.roll}.should raise_error(ArgumentError)
        end
        it "can count successes" do
          @exalted.roll(:pool=>10)
          10.times do
            sux = @exalted.pool.count {|die| die.result >= 7 } + @exalted.pool.count {|die| die.result == 10 } 
            @exalted.effects.should == [sux, nil]
          end
        end
      end
      
    end
    
    context "use it like a table" do
      
      before :each do
        ill_fortune = Roll.new(1.d10) do
          equals 1, "Accident"
          equals 2, "Maltreatment"
          equals 3, "Disease"
          equals 4, "Dropped"
          equals 5, "Parental Loss"
          equals 6, "Family Loss"
          equals 7, "Torment"
          equals 8, "Homeless"
          equals 9, "Ghost"
          equals 10, "Prying Eyes"
        end
        good_fortune = Roll.new(1.d10) do
          equals 1, "Dreamer"
          equals 2, "Childhood Patron"
          equals 3, "Active Youth"
          equals 4, "Apt Pupil"
          equals 5, "Save a Life"
          equals 6, "First Love"
          equals 7, "Childhood Friend"
          equals 8, "Heirloom"
          equals 9, "Spirit Blessing"
          equals 10, "Temple Assistant"
        end
        @childhood_event = Roll.new(1.d10) do
          equals (1..4), "Roll on ill fortune table", ill_fortune
          equals (5..8), "Roll on good fortune table", good_fortune
          equals (9..10), "Roll on both ill and good fortune tables", ill_fortune, good_fortune
        end
      end
      
      it "can compose multiple nested results" do
        20.times do
          @childhood_event.roll
          if @childhood_event.effects[0] >= 9
            @childhood_event.effects.length.should == 4
          else
            @childhood_event.effects.length.should == 3
          end
        end
      end
    end
    
  end
end