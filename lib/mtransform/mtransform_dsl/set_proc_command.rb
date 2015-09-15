module Mtransform
  class MtransformDSL
    class SetProcCommand
      attr_reader :data

      def initialize(key, &block)
        raise ArgumentError unless block_given?
        raise ArgumentError unless key.is_a? Symbol
        @data = { key => block }
      end

      def run(input, output)
        Hash.new.tap do |result|
          data.each do |key, block|
            result[key] = block.call(input, output)
          end
        end
      end
    end
  end
end
