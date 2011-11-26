require 'peano/peano'
require 'rantly/property'
require 'rspec'

class RSpec::Core::ExampleGroup
  def property_of(&block)
    Rantly::Property.new(block)
  end
end

class Rantly
  def peano(limit = nil)
    limit = 0..Peano::MAX_INT if limit.nil?
    Peano.from_i(integer(limit))
  end

module Peano
  class PNumber
    def self.generator(limit = nil)
      limit = 0..Peano::MAX_INT if limit.nil?
      Peano.from_i(Rantly.gen.integer(limit))
    end
  end
end

module Peano
  describe "Peano" do
    it "should have Zero identifiable" do
      property_of {
        PNumber.generator
      }.check {|i|
        i.zero?.should == i.kind_of?(Zero)
      }
    end

    it "should 0 < n" do
      property_of {
        PNumber.generator(1..100)
      }.check { |n|
        Peano.zero.should < n
      }
    end

    it "should fail 0.pred" do
      property_of {
        Peano.from_i(0)
      }.check { |zero|
        ->{ zero.pred }.should raise_error(NoPredError)
      }
    end

    it "should succ(pred(n)) == n" do
      property_of {
        PNumber.generator(0..Peano::MAX_INT - 1)
      }.check {|n|
        n.succ.pred.should == n
      }
    end

    it "should pred(n) < n like integer's <" do
      property_of {
        i = integer(1..Peano::MAX_INT)
        [i, i-1].map{|n| Peano.from_i(n)}
      }.check {|n, pred_n|
        pred_n.should < n
      }
    end

    it "should pred(n) < n" do
      property_of {
        PNumber.generator(1..Peano::MAX_INT)
      }.check {|n|
        n.pred.should < n
      }
    end

    it "should succ(n) > n like integer's >" do
      property_of {
        i = range(0, Peano::MAX_INT - 1)
        [i, i+1].map{|n| Peano.from_i(n)}
      }.check { |n, succ_n|
         n.should < succ_n
      }
    end

    it "should succ(n) > n" do
      property_of {
        PNumber.generator(0..Peano::MAX_INT - 1)
      }.check {|n|
        n.should < n.succ
      }
    end

    it "should define < as integer's <" do
      property_of {
        i = range(1, Peano::MAX_INT)
        [i, range(0, i - 1)].map{|n| Peano.from_i(n)}
      }.check {|i, less_than_i|
        less_than_i.should < i
      }
    end

    it "should have Zero as the additive identity" do
      property_of {
        i = PNumber.generator(0..Peano::MAX_INT - 1)
        [i, i + Zero.new, Zero.new + i]
      }.check {|i, i_plus_zero, zero_plus_i|
        i.should == i_plus_zero
        i_plus_zero.should == i

        i.should == zero_plus_i
        zero_plus_i.should == i
      }
    end

    it "should define + like the integers" do
      property_of {
        i = PNumber.generator(0..Peano::MAX_INT / 2)
        j = PNumber.generator(0..Peano::MAX_INT / 2)
        [i, j]
      }.check {|i, j|
        (i + j).to_i.should == (i + j)
      }
    end

    it "should reduce an array of Peano numbers" do
      property_of {
        sized(integer(1..10)) {
          array { PNumber.generator(0..Peano::MAX_INT / 10) }
        }
      }.check {|numbers|
        numbers.reduce(:+).should == (numbers.map{|p| p.to_i}.reduce(:+))
      }
    end
  end
end
