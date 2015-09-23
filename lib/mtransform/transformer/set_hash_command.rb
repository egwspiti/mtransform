module Mtransform
  class Transformer
    # SetHashCommand class encapsulates a set_hash transformation.
    #
    # The configuration of the transformation is provided by the hash argument
    # to the constructor.
    class SetHashCommand

      # @return [Hash] the hash for the set_hash transformation.
      attr_reader :hash

      # @param [Hash] hash hash for the set_hash transformation.
      def initialize(hash)
        @hash = hash
      end

      # set_hash transformation of input
      #
      # Copy keys values from hash attribute to the output hash.
      #
      # @param [Hash] _input
      #   Unused, the output of this transformation is not related to the input hash
      # @return [Hash]
      #   output hash, practically the hash attribute
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
