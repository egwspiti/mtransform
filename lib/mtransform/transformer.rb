require 'mtransform/transformer/commands'
require 'mtransform/transformer/as_is_command'
require 'mtransform/transformer/rename_command'
require 'mtransform/transformer/set_hash_command'
require 'mtransform/transformer/set_proc_command'

module Mtransform
  class Transformer

    # @return [Commands] the commands collection
    attr_reader :commands

    # @return [Object] context where blocks for commands that require a block
    #   will be executed.
    attr_reader :context

    # Setup commands and context, then evaluate the passed block.
    #
    # @param [Object] context context where blocks for commands that require
    #   a block will be executed.
    # @param block block to be evaluated on the constructed instance of Transformer
    def initialize(context = nil, &block)
      @commands = Commands.new
      @context = context
      instance_eval(&block)
    end

    # Register an as_is transformation
    #
    # @param [Array<Object>] keys keys for the as_is transformation
    def as_is(*keys)
      commands.add_command_without_block(AsIsCommand.new(keys))
    end

    # Register a rename transformation
    #
    # @param [Hash] hash hash for the rename transformation
    #
    # @raise [ArgumentError] if not given a hash
    def rename(hash)
      raise ArgumentError, 'Argument is not a Hash' unless hash.is_a? Hash
      commands.add_command_without_block(RenameCommand.new(hash))
    end

    # Register a rest transformation
    #
    # @param action action for the rest transformation
    def rest(action)
      commands.rest = action
    end

    # Register a set_proc / set_hash transformation
    #
    # @overload set(arg)
    #   Register a set_hash transformation
    #   @param [Hash] arg hash for the set_hash transformation
    #
    # @overload set(key, &block)
    #   Register a set_proc transformation
    #   @param [Symbol] key key for the set_proc transformation
    #   @param block lbock for the set_proc transformation
    #   @raise [ArgumentError] if no block given
    def set(arg, &block)
      case arg
      when Hash
        commands.add_command_without_block(SetHashCommand.new(arg))
      when Symbol
        raise ArgumentError, 'No block given' unless block_given?
        commands.add_command_with_block(SetProcCommand.new(arg, context, &block))
      else
        raise ArgumentError, 'No Hash or Symbol argument given'
      end
    end

    # Transform input by running the registered transformations.
    #
    # @param [Hash] input input hash to be transformed
    def transform(input)
      commands.run(input)
    end
  end
end
