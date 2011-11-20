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
      raise "Peano arithmetic only defined over the range [0, #{MAX_INT.to_s}]"
    end
  end

  class PNumber
    def < (obj)
      raise ":< not defined for #{self.class.name}"
    end

    def pred
      raise ":pred not defined for #{self.class.name}"
    end

    def succ
      raise ":succ not defined for #{self.class.name}"
    end
  end

  class Zero < PNumber
    def inspect
      "#<Zero>"
    end

    def <(obj)
      not obj.kind_of?(Zero)
    end

    def pred
      raise NoPredError.new
    end

    def succ
      Succ.new(self)
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
    def inspect
      "#<Succ #{@pred}>"
    end

    def <(obj)
      pred < obj.pred
    end

    def succ
      Succ.new(self)
    end
    
    def to_i
      @pred.to_i + 1
    end
  end
end
