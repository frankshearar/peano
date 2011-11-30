module Peano
  def Recur(&block)
    Trampoline.run(block)
  end

  class Trampoline
    def run(&block)
      result = block.call
      while result.kind_of?(Proc) do
        result = result.call
      end
      result
    end
  end
end
