module Mtransform
  class Transformer
    # SetProcCommand class encapsulates a set_proc transformation.
    #
    # The configuration of the transformation is provided by the key, context,
    # block arguments to the contructor.
    #
    # When #run, the block is executed into the specified context. Immutable
    # copies of both input and output hash are made available as block parameters.
    class SetProcCommand

      # @return [Hash]
      #   the key of the hash is the key of the set_proc transformation
      #   the value of the hash is the block of the set_proc transformation
      attr_reader :data

      # @return [Object] the object where the transformation block will be
      #   executed.
      attr_reader :context

      # Initialize a SetProcCommand for the given key, context and block.
      #
      # @param [Hash] key key of the set_proc transformation.
      # @param [Object] context context where the transformation block will be
      #   executed.
      # @yield [input, output] immutable copies of both input and output hash
      #   are made available as block parameters.
      def initialize(key, context, &block)
        @data = { key => block }
        @context = context || self
      end

      # set transformation of input
      #
      # Copy keys values from hash attribute to the output hash.
      #
      # @param [Hash] input
      #   input hash
      # @param [Hash] output
      #   output hash of previous transformations
      # @return [Hash]
      #   output hash, practically the hash attribute
      def run(input, output)
        input  = input.dup.freeze
        output = output.dup.freeze
        {}.tap do |result|
          data.each do |key, block|
            result[key] = context.instance_exec(input, output, &block)
          end
        end
      end
    end
  end
end
