module Mtransform
  class Transformer
    # Commands class encapsulates collections of commands.
    #
    # A command is a class that implements a #run method. This #run method can
    # either expect or not a block. Thus two lists of commands are maintained.
    #
    # Instances of commands can be added to these lists using #add_command_with_block
    # and #add_commmand_without_block respectively.
    #
    # These commands can be #run on an input hash effectively applying each command
    # to the input hash.
    class Commands

      # @return [Array<#run>] the maintained list of commands whose #run does
      #   not expect a block.
      attr_reader :commands_without_block

      # @return [Array<#run>] the maintained list of commands whose #run
      #   expects a block.
      attr_reader :commands_with_block

      # Setup a list for commands whore #run expect a block and a list for
      # commands whose #run does not expect a block.
      def initialize
        @commands_without_block = []
        @commands_with_block = []
      end

      # Add a command that does not expect a block for its #run into the appropriate
      # commmand list.
      #
      # @param [#run] command command to be added
      # @return [Array<#run>] the maintained list of commands whose #run does
      #   not expect a block.
      def add_command_without_block(command)
        commands_without_block << command
      end

      # Add a command that expects a block for its #run into the appropriate
      # commmand list.
      #
      # @param [#run] command command to be added
      # @return [Array<#run>] the maintained list of commands whose #run
      #   expects a block.
      def add_command_with_block(command)
        commands_with_block << command
      end

      # @param [Symbol] action action for keys / values present in input but not
      #   in output hash after the excecution of all other transformations
      # @return [Symbol] given action
      #
      # @raise [ArgumentError] if action is neither :keep nor :delete
      def rest=(action)
        raise ArgumentError, 'Not a valid action. Only :keep and :delete are supported' unless action == :keep || action == :delete
        @rest_action = action
      end

      # Run commands on input
      #
      # @param [Hash] input
      #   input hash
      # @return [Hash]
      #   output hash, the result of commands applied to input hash
      #
      # @raise [ArgumentError] if input does not implement #[]
      def run(input)
        raise ArgumentError, 'Input arg does not implement #[]' unless input.respond_to?(:[])

        output = commands_without_block.inject({}) do |acc, command|
          command_output = command.run(input)
          acc.merge(command_output)
        end

        commands_with_block.each do |command|
          output.merge!(command.run(input, output))
        end

        output.merge!(keep_rest(input, input.keys - output.keys)) if keep_rest?
        output
      end

      private

      def keep_rest?
        @rest_action == :keep
      end

      def keep_rest(input, rest_keys)
        {}.tap do |result|
          rest_keys.each do |key|
            result[key] = input[key]
          end
        end
      end
    end
  end
end
