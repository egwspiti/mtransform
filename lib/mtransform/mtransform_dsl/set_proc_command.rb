module Mtransform
  class MtransformDSL
    class SetProcCommand
      attr_reader :data, :context

      def initialize(key, context, &block)
        raise ArgumentError unless block_given?
        raise ArgumentError unless key.is_a? Symbol
        @data = { key => block }
        @context = context || self
      end

      def run(input, output)
        Hash.new.tap do |result|
          data.each do |key, block|
            result[key] = context.instance_exec(input, output, &block)
          end
        end
      end
    end
  end
end
