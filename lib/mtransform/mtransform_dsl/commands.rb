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
        map do |command|
          case command.method(:run).arity
          when 0
            command.run
          when 1
            command.run(input)
          end
        end.inject(&:merge)
      end
    end
  end
end
