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

      def rest=(action)
        raise ArgumentError unless action == :keep || action == :delete
        @rest_action = action
      end

      def keep_rest?
        @rest_action == :keep
      end

      def run
        after = []

        output = inject({}) do |acc, command|
          command_output =  case command.method(:run).arity
                            when 0
                              command.run
                            when 1
                              command.run(input)
                            when 2
                              after << command
                              {}
                            end
          acc.merge(command_output)
        end

        after.each do |command|
          output.merge!(command.run(input, output))
        end

        output.merge!(keep_rest(input.keys - output.keys)) if keep_rest?
        output
      end

      private

      def keep_rest(rest_keys)
        Hash.new.tap do |result|
          rest_keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
