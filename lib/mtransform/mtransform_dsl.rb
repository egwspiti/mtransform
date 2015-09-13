module Mtransform
  class MtransformDSL
    attr_reader :input, :output, :cmds, :order

    def initialize(hash, &b)
      @input  = hash
      @output = {}
      @cmds   = { as_is: [], rename: [] }
      @order = []
      instance_eval(&b)
    end

    def as_is(*keys)
      raise ArgumentError unless keys.all? { |key| key.is_a? Symbol }
      order << :as_is
      cmds[:as_is] << keys
    end

    def rename(hash)
      raise ArgumentError unless hash.respond_to?(:keys) && hash.respond_to?(:values) && hash.respond_to?(:all?)
      raise ArgumentError unless (hash.keys + hash.values).all? { |key| key.is_a? Symbol }
      order << :rename
      cmds[:rename] << hash
    end

    def transform
      order.each do |cmd|
        case cmd
        when :as_is
          keys = cmds[:as_is].shift
          run_as_is(keys)
        when :rename
          hash = cmds[:rename].shift
          run_rename(hash)
        end
      end
      output
    end

    private

    def run_as_is(*keys)
      keys.flatten.each do |key|
        output[key] = input[key]
      end
    end

    def run_rename(hash)
      hash.each do |from, to|
        output[to] = input[from]
      end
    end
  end
end
