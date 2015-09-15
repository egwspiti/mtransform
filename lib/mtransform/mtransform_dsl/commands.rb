require 'forwardable'

module Mtransform
  class MtransformDSL
    class Commands
      extend Forwardable
      include Enumerable

      def_delegators :commands, :each, :<<
      attr_reader :commands, :input

      def initialize(input)
        @input = input
        @commands = []
      end

      def run
        after = []
        output = inject({}) do |output, command|
          case command.method(:run).arity
          when 0
            output.merge!(command.run)
          when 1
            output.merge!(command.run(input))
          when 2
            after << command
          end
          output
        end
        after.each do |command|
          output.merge!(command.run(input, output))
        end
        output
      end
    end
  end
end
