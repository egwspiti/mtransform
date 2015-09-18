module Mtransform
  class Transformer
    class AsIsCommand
      attr_reader :keys

      def initialize(*keys)
        keys.flatten!
        raise ArgumentError, 'Not all arguments are Symbol' unless keys.all? { |key| key.is_a? Symbol }
        @keys = keys
      end

      def run(input)
        Hash.new.tap do |result|
          keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
