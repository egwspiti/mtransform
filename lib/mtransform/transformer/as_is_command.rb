module Mtransform
  class Transformer
    class AsIsCommand
      attr_reader :keys

      def initialize(*keys)
        keys.flatten!
        @keys = keys
      end

      def run(input)
        {}.tap do |result|
          keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
