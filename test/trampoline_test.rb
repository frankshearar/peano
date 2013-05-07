require_relative 'test_helper'
require 'peano/trampoline'
require 'rantly/property'
require 'rspec'

module Peano
  describe "Trampoline" do
    it "should permit arbitrarily large amounts of recursion" do
      property_of {
        integer(0..100)
      }.check{ |n|
        t = TrampolineTest.new
        Trampoline.new.run {
          t.recurrence(n)
        }.should == "result!"
        t.logged_return_vals.length.should == n + 1 # 0 counts too!
      }
    end

    it "should pass exceptions" do
      ->{
        Trampoline.new.run { raise "this is an exception" }
      }.should raise_error("this is an exception")
    end

    it "should pass exceptions raised inside recursion" do
      ->{
        Trampoline.new.run { TrampolineTest.new.raise_when_zero(10)}
      }.should raise_error("Zero!")
    end
  end

  class TrampolineTest
    attr_reader :logged_return_vals
    def initialize
      @logged_return_vals = []
    end

    def recurrence(n)
      @logged_return_vals << n
      if n > 0 then
        ->{recurrence(n - 1)}
      else
        "result!"
      end
    end

    def raise_when_zero(n)
      if n > 0 then
        ->{raise_when_zero(n - 1)}
      else
        raise "Zero!"
      end
    end
  end
end
