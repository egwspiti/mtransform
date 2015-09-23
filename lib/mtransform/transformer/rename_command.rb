module Mtransform
  class Transformer
    # RenameCommand class encapsulates a rename transformation.
    #
    # The configuration of the transformation is provided by the hash argument
    # to the constructor.
    class RenameCommand

      # @return [Hash] the hash for the rename transformation.
      attr_reader :hash

      # @param [Hash] hash hash for the rename transformation.
      def initialize(hash)
        @hash = hash
      end

      # rename transformation of input
      #
      # Copy values from input hash for the keys of the hash attribute. The
      # value of each key in the hash attribute specifies the key at the output
      # hash where the value will be copied.
      #
      # @note No action is taken to ensure the presence of a key in the input hash.
      #   Thus for missing keys the default values are copied.
      #
      # @param [Hash] input
      #   input hash
      # @return [Hash]
      #   output hash
      def run(input)
        {}.tap do |result|
          hash.each do |from, to|
            result[to] = input[from]
          end
        end
      end
    end
  end
end
