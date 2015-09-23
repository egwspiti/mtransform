module Mtransform
  class Transformer
    # AsIsCommand class encapsulates an as_is transformation.
    #
    # The configuration of the transformation is provided by the keys argument
    # to the constructor.
    class AsIsCommand

      # @return [Array<Object>] the keys for the as_is transformation.
      attr_reader :keys

      # @param [Array<Object>] keys keys for the as_is transformation.
      def initialize(*keys)
        keys.flatten!
        @keys = keys
      end

      # as_is transformation of input
      #
      # Copy values from input hash to output hash for keys
      # specified by keys attribute.
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
          keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
