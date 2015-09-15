module Mtransform
  class MtransformDSL
    class SetProcCommand
      attr_reader :data

      def initialize(key, &block)
        raise ArgumentError unless block_given?
        raise ArgumentError unless key.is_a? Symbol
        @data = { key => block }
      end

      def run(_)
        Hash.new.tap do |output|
          data.each do |key, block|
            output[key] = instance_exec(&block)
          end
        end
      end
    end
  end
end
