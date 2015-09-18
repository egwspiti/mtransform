module Mtransform
  class Transformer
    class RenameCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError, 'Argument is not a Hash' unless hash.is_a? Hash
        raise ArgumentError, 'Argument does not implement #keys' unless hash.respond_to?(:keys)
        raise ArgumentError, 'Argument does not implement #values' unless hash.respond_to?(:values)
        raise ArgumentError, 'Argument does not implement #each' unless hash.respond_to?(:each)
        raise ArgumentError, 'Not all keys and values are Symbol' unless (hash.keys + hash.values).all? { |key| key.is_a? Symbol }
        @hash = hash
      end

      def run(input)
        Hash.new.tap do |result|
          hash.each do |from, to|
            result[to] = input[from]
          end
        end
      end
    end
  end
end
