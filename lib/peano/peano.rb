require 'peano/trampoline'

module Peano
  def self.zero
    Zero.new
  end

  def self.from_i(integer)
    if (integer < 0) then
      Inv.new(Trampoline.new.run { make_succ(-integer) })
    elsif (integer > 0) then
      Trampoline.new.run { make_succ(integer) }
    else
      Zero.new
    end
  end

  class PNumber
    def < (peano)
      Trampoline.new.run {self.__less_than(peano)}
    end

    def ==(peano)
      Trampoline.new.run {self.__equals(peano)}
    end

    def hash
      to_i
    end

    def >(peano)
      not (self == peano) and not (self < peano)
    end

    def +(peano)
      Trampoline.new.run {self.__plus(peano)}
    end

    def inv
      raise UndefinedOp.new(:inv)
    end

    def pred
      raise UndefinedOp.new(:pred)
    end

    def succ
      Succ.new(self)
    end

    def zero?
      false
    end

    def __equals(peano)
      raise UndefinedOp.new(:==, peano)
    end

    def __less_than(peano)
      raise UndefinedOp.new(:>, peano)
    end

    def __plus(peano)
      raise UndefinedOp.new(:+, peano)
    end
  end

  class Zero < PNumber
    def to_i
      0
    end

    def to_s
      'Z'
    end

    def inspect
      "#<Zero>"
    end

    def >(obj)
      false
    end

    def zero?
      true
    end

    def inv
      self
    end

    def pred
      Inv.new(Succ.new(self))
    end

    def __less_than(obj)
      not obj.kind_of?(Zero)
    end

    def __equals(peano)
      peano.zero?
    end

    def __plus(peano)
      case peano
        when Zero then self
      else
        peano
      end
    end
  end

  class Succ < PNumber
    attr_reader :pred

    def initialize(pred)
      @pred = pred
    end

    def to_i
      @pred.to_i + 1
    end

    def to_s
      "S(#{pred.to_s})"
    end

    def inspect
      "#<Succ #{@pred.inspect}>"
    end

    def inv
      Inv.new(self)
    end

    def __less_than(peano)
      case peano
        when Zero then false
        when Succ then ->{pred.__less_than(peano.pred)}
        when Inv then false
        else super
      end
    end

    def __equals(peano)
      case peano
        when Zero then false
        when Succ then ->{pred.__equals(peano.pred)}
        when Inv then false
        else super
      end
    end

    def __plus(peano)
      case peano
        when Zero then self
        when Succ then ->{succ.__plus(peano.pred)}
        when Inv then ->{pred.__plus(peano.succ)}
        else super
      end
    end
  end

  # I represent the inverse of a number.
  # Inv(Zero) == Zero, Inv(Inv(apnumber)) == apnumber
  class Inv < PNumber
    attr_reader :inverse

    def initialize(inverse)
      # inverse is, of course, the inverse of self.
      # Or, self is the inverse of inverse!

      @inverse = inverse
    end

    def to_i
      - @inverse.to_i
    end

    def to_s
      "I(#{inverse.to_s})"
    end

    def inspect
      "#<Inv #{@inverse.inspect}>"
    end

    def inv
      @inverse
    end

    def pred
      Inv.new(inverse.succ)
    end

    def succ
      Inv.new(inverse.pred)
    end

    def __equals(peano)
      case peano
        when Zero then false
        when Succ then false
      when Inv then ->{inv.__equals(peano.inverse)}
        else super
      end
    end

    def __less_than(peano)
      case peano
        when Zero then true
        when Succ then true
        when Inv then inverse > peano.inverse
      else super
      end
    end

    def __plus(peano)
      case peano
        when Zero then self
        when Succ then ->{succ.__plus(peano.pred)}
        when Inv then ->{Inv.new(inverse.__plus(peano.inverse))}
        else super
      end
    end
  end

  class PeanoError < Exception
  end

  class UndefinedOp < PeanoError
    def initialize(op_name, *operands)
      classes = ([self.class.name] + operands.map {|o| o.class.name}).join(", ")
      super("#{op_name.to_s} not defined for (#{classes})")
    end
  end

  # Tail recursive helper for from_i
  def self.make_succ(integer, base = Zero.new)
    if integer > 0 then
      ->{make_succ(integer - 1, Succ.new(base))}
    else
      base
    end
  end
end
