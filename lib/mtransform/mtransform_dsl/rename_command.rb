module Mtransform
  class MtransformDSL
    class RenameCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError unless hash.respond_to?(:keys) && hash.respond_to?(:values)
        raise ArgumentError unless (hash.keys + hash.values).all? { |key| key.is_a? Symbol }
        @hash = hash
      end

      def run(input)
        output = {}
        hash.each do |from, to|
          output[to] = input[from]
        end
        output
      end
    end
  end
end
