require 'forwardable'

module Mtransform
  class Transformer
    class Commands
      extend Forwardable
      include Enumerable

      def_delegators :commands, :each, :<<
      attr_reader :commands, :commands_with_block

      def initialize
        @commands = []
        @commands_with_block = []
      end

      def rest=(action)
        raise ArgumentError, 'Not a valid action. Only :keep and :delete are supported' unless action == :keep || action == :delete
        @rest_action = action
      end

      def keep_rest?
        @rest_action == :keep
      end

      def run(input)
        raise ArgumentError, 'Input arg does not implement #[]' unless input.respond_to?(:[])

        output = inject({}) do |acc, command|
          command_output =  case command.method(:run).arity
                            when 0
                              command.run
                            when 1
                              command.run(input)
                            end
          acc.merge(command_output)
        end

        commands_with_block.each do |command|
          output.merge!(command.run(input, output))
        end

        output.merge!(keep_rest(input, input.keys - output.keys)) if keep_rest?
        output
      end

      private

      def keep_rest(input, rest_keys)
        Hash.new.tap do |result|
          rest_keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
