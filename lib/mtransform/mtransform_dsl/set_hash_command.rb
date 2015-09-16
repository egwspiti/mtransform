module Mtransform
  class MtransformDSL
    class SetHashCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError unless hash.is_a? Hash
        raise ArgumentError unless hash.respond_to?(:keys) && hash.respond_to?(:each)
        raise ArgumentError unless hash.keys.all? { |key| key.is_a? Symbol }
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
