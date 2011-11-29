module Peano
  # Lack of tail call elimination means stack-blowing. So we artificially
  # limit the domain of discourse.
  MAX_INT = 1000

  class PeanoError < Exception
  end

  class NoPredError < PeanoError
  end

  def self.zero
    Zero.new
  end

  def self.from_i(integer)
    case integer
      when 0 then Zero.new
      when 1..MAX_INT then Succ.new(from_i(integer - 1))
    else
      raise "Peano arithmetic only defined over the range [0, #{MAX_INT.to_s}]. You gave #{integer.inspect}."
    end
  end

  class PNumber
    def < (obj)
      raise ":< not defined for #{self.class.name}"
    end

    def == (obj)
      raise ":== not defined for #{self.class.name}"
    end

    def > (peano)
      raise ":> not defined for #{self.class.name}"
    end

    def + (obj)
      raise ":+ not defined for #{self.class.name}"
    end

    def pred
      raise ":pred not defined for #{self.class.name}"
    end

    def succ
      Succ.new(self)
    end

    def zero?
      false
    end
  end

  class Zero < PNumber
    def to_s
      'Z'
    end

    def inspect
      "#<Zero>"
    end

    def <(obj)
      not obj.kind_of?(Zero)
    end

    def >(obj)
      false
    end

    def ==(peano)
      peano.zero?
    end

    def +(peano)
      case peano
        when Zero then self
      else
        peano
      end
    end

    def zero?
      true
    end

    def pred
      raise NoPredError.new
    end

    def to_i
      0
    end
  end

  class Succ < PNumber
    attr_reader :pred

    def initialize(pred)
      @pred = pred
    end

    def to_s
      "S(#{pred.to_s})"
    end

    def inspect
      "#<Succ #{@pred.inspect}>"
    end

    def <(obj)
      case obj
        when Zero then false
        when Succ then pred < obj.pred
      else
        raise "< not defined for (Succ, #{obj.class.name})"
      end
    end

    def >(peano)
      not (self == peano) and not (self < peano)
    end

    def ==(peano)
      return false if peano.nil?

      case peano
        when Zero then false
        when Succ then self.pred == peano.pred
      end
    end

    def +(peano)
      case peano
      when Zero then self
      else
        self.succ + peano.pred
      end
    end

    def to_i
      @pred.to_i + 1
    end
  end
end
