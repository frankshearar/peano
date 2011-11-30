require 'peano/peano'
require 'peano/rspec-ext'
require 'rantly/property'
require 'rspec'

class Rantly
  def peano(limit = nil)
    limit = 0..1000 if limit.nil?
    Peano.from_i(integer(limit))
  end
end

module Peano
  class PNumber
    def self.generator(limit = nil)
      limit = 0..1000 if limit.nil?
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

    it "should allow inverses" do
      property_of {
        Peano.from_i(integer(-1000..-1))
      }.check { |i|
        i.class.should == Inv
      }
    end

    it "should have Inv(Inv(n)) == n" do
      property_of {
        i = PNumber.generator
      }.check { |i|
        i.inv.inv.should == i
      }
    end

    it "should have Inv(0) == 0" do
      property_of {
        Peano.from_i(0)
      }.check { |zero|
        zero.inv.should == zero
        zero.inv.should be_zero
      }
    end

    it "should 0 < n for Succ" do
      property_of {
        PNumber.generator(1..100)
      }.check { |n|
        Peano.zero.should < n
      }
    end

    it "should succ(pred(n)) == n" do
      property_of {
        PNumber.generator
      }.check {|n|
        n.succ.pred.should == n
      }
    end

    it "should pred(n) < n like integer's <" do
      property_of {
        i = integer(1..1000)
        [i, i-1].map{|n| Peano.from_i(n)}
      }.check {|n, pred_n|
        pred_n.should < n
      }
    end

    it "should pred(n) < n" do
      property_of {
        PNumber.generator(-1000..1000)
      }.check {|n|
        n.pred.should < n
      }
    end

    it "should succ(n) > n like integer's >" do
      property_of {
        i = range(-1000, 1000)
        [i, i+1].map{|n| Peano.from_i(n)}
      }.check { |n, succ_n|
         n.should < succ_n
      }
    end

    it "should succ(n) > n" do
      property_of {
        PNumber.generator
      }.check {|n|
        n.succ.should > n
      }
    end

    it "should n < succ(n)" do
      property_of {
        PNumber.generator
      }.check {|n|
        n.should < n.succ
      }
    end

    it "should define < as integer's <" do
      property_of {
        i = range(1, 1000)
        [i, range(-1000, i - 1)].map{|n| Peano.from_i(n)}
      }.check {|i, less_than_i|
        less_than_i.should < i
        i.should_not < less_than_i
      }
    end

    it "should define > as integer's >" do
      property_of {
        i = range(-1000, 0)
        [i, range(i + 1, 1000)].map{|n| Peano.from_i(n)}
      }.check {|i, more_than_i|
        more_than_i.should > i
        i.should_not > more_than_i
      }
    end

    it "should have Zero as the additive identity" do
      property_of {
        i = PNumber.generator
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
        i = PNumber.generator
        j = PNumber.generator
        [i, j]
      }.check {|i, j|
        (i + j).to_i.should == (i.to_i + j.to_i)
      }
    end

    it "should add negative and positive integers" do
      property_of {
        i = peano
        j = peano.inv
        choose([i, j], [j, i])
      }.check{ |i, j|
        (i + j).to_i.should == i.to_i + j.to_i
      }
    end

    it "should reduce an array of Peano numbers" do
      property_of {
        sized(integer(1..10)) {
          array { PNumber.generator }
        }
      }.check {|numbers|
        numbers.reduce(:+).to_i.should == (numbers.map{|p| p.to_i}.reduce(:+))
      }
    end

    it "should define == like the integers" do
      property_of {
        PNumber.generator
      }.check {|n|
        n.should == n
      }

      property_of {
        i = integer(-1000..1000)
        j = integer(-1000..1000)
        guard i != j
        [i, j].map {|n| Peano.from_i(n)}
      }.check {|i, j|
        i.should_not == j
      }
    end
  end
end
