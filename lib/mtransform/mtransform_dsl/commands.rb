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
          command.run(input)
        end.inject(&:merge)
      end
    end
  end
end
