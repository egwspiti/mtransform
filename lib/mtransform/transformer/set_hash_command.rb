module Mtransform
  class Transformer
    class SetHashCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError, 'Argument is not a Hash' unless hash.is_a? Hash
        raise ArgumentError, 'Argument does not implement #keys' unless hash.respond_to?(:keys)
        raise ArgumentError, 'Argument does not implement #each' unless hash.respond_to?(:each)
        raise ArgumentError, 'Not all keys are Symbol' unless hash.keys.all? { |key| key.is_a? Symbol }
        @hash = hash
      end

      def run
        Hash.new.tap do |result|
          hash.each do |key, value|
            result[key] = value
          end
        end
      end
    end
  end
end
