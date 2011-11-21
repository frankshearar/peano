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
    should "have Zero identifiable" do
      property_of {
        peano
      }.check {|i|
        assert_equal(i.zero?, i.kind_of?(Zero), "Mis-identified as Zero: #{i.to_s}")
      }
    end

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
        [i, range(0, i - 1)].map{|n| Peano.from_i(n)}
      }.check {|i, less_than_i|
        assert(less_than_i < i, "#{less_than_i.to_s} >= #{i.to_s}")
      }
    end

    should "have Zero as the additive identity" do
      property_of {
        i = peano(0..Peano::MAX_INT - 1)
        [i, i + Zero.new, Zero.new + i]
      }.check {|i, i_plus_zero, zero_plus_i|
        assert_equal(i, i_plus_zero, "i != i + 0")
        assert_equal(i_plus_zero, i, "i + 0 != i")

        assert_equal(i, zero_plus_i, "i != 0 + i")
        assert_equal(zero_plus_i, i, "0 + i != i")
      }
    end

    should "define + like the integers" do
      property_of {
        i = peano(0..Peano::MAX_INT / 2)
        j = peano(0..Peano::MAX_INT / 2)
        [i, j]
      }.check {|i, j|
        assert_equal((i + j).to_i, i + j, "+ in Peano not isomorphic to + in N")
      }
    end

    should "reduce an array of Peano numbers" do
      property_of {
        sized(integer(1..10)) {
          array { peano(0..Peano::MAX_INT / 10) }
        }
      }.check {|numbers|
        assert_equal(numbers.reduce(:+), numbers.map{|p| p.to_i}.reduce(:+), "Arrays of numbers")
      }
    end

    # should "wtf" do
    #   flag = true
    #   property_of {
    #     [sized(3) {array {peano(0..5)}}, sized(10) {array {peano(0)}}]
    #   }.check {|thing|
    #     if flag then
    #       flag = false
    #       puts "#{thing[0].size} #{thing[1].size}"
    #     end
    #   }
    # end
  end
end
