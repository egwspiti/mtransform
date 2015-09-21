module Mtransform
  class Transformer
    class SetProcCommand
      attr_reader :data, :context

      def initialize(key, context, &block)
        raise ArgumentError, 'No block given' unless block_given?
        @data = { key => block }
        @context = context || self
      end

      def run(input, output)
        input  = input.dup.freeze
        output = output.dup.freeze
        Hash.new.tap do |result|
          data.each do |key, block|
            result[key] = context.instance_exec(input, output, &block)
          end
        end
      end
    end
  end
end
