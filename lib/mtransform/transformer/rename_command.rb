module Mtransform
  class Transformer
    class RenameCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError unless hash.is_a? Hash
        raise ArgumentError unless hash.respond_to?(:keys) && hash.respond_to?(:values) && hash.respond_to?(:each)
        raise ArgumentError unless (hash.keys + hash.values).all? { |key| key.is_a? Symbol }
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