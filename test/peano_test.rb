require 'peano/peano'
require 'rantly/property'
require 'shoulda'

class Rantly
  def peano(limit = nil)
    limit = 0..Peano::MAX_INT if limit.nil?
    Peano.from_i(integer(limit))
  end
end

module Peano
  class Test < Test::Unit::TestCase
    should "0 < n" do
      property_of {
        peano(1..100)
      }.check { |n|
        assert(Peano.zero < n, "Zero >= #{n.to_s}")
      }
    end

    should "pred(0) fails" do
      property_of {
        Peano.from_i(0)
      }.check { |zero|
        assert_raise(NoPredError) {
          zero.pred
        }
      }
    end

    should "succ(pred(n)) == n" do
      property_of {
        peano(1..Peano::MAX_INT)
      }.check {|n|
        n.succ.pred == n
      }
    end

    should "pred(n) < n" do
      property_of {
        i = integer(1..Peano::MAX_INT)
        [i, i-1].map{|n| Peano.from_i(n)}
      }.check {|n, pred_n|
        assert(pred_n < n, "#{pred_n.to_s} >= #{n.to_s}")
      }
    end

    should "succ(n) > n" do
      property_of {
        i = range(0, Peano::MAX_INT - 1)
        [i, i+1].map{|n| Peano.from_i(n)} 
      }.check { |n, succ_n|
         assert(n < succ_n, "#{n.to_s} >= #{succ_n.to_s}")
      }
    end

    should "define < as integer's <" do
      property_of {
        i = range(1, Peano::MAX_INT)
        [i, range(0, i - 1)].map { |n| Peano.from_i(n) }
      }.check {|i, less_than_i|
        assert(less_than_i < i, "#{less_than_i.inspect} >= #{i.inspect}")
      }
    end
  end
end
