module Mtransform
  class MtransformDSL
    class AsIsCommand
      attr_reader :keys

      def initialize(*keys)
        keys.flatten!
        raise ArgumentError unless keys.all? { |key| key.is_a? Symbol }
        @keys = keys
      end

    def run(input)
      output = {}
      keys.each do |key|
        output[key] = input[key]
      end
      output
    end
    end
  end
end
