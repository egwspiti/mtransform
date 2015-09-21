module Mtransform
  class Transformer
    class SetHashCommand
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def run(_input)
        {}.tap do |result|
          hash.each do |key, value|
            result[key] = value
          end
        end
      end
    end
  end
end
