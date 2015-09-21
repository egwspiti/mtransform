require 'mtransform/transformer/commands'
require 'mtransform/transformer/as_is_command'
require 'mtransform/transformer/rename_command'
require 'mtransform/transformer/set_hash_command'
require 'mtransform/transformer/set_proc_command'

module Mtransform
  class Transformer
    attr_reader :commands, :context

    def initialize(context = nil, &block)
      @commands = Commands.new
      @context = context
      instance_eval(&block)
    end

    def as_is(*keys)
      commands.add_command_without_block(AsIsCommand.new(keys))
    end

    def rename(hash)
      raise ArgumentError, 'Argument is not a Hash' unless hash.is_a? Hash
      commands.add_command_without_block(RenameCommand.new(hash))
    end

    def rest(action)
      commands.rest = action
    end

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

    def transform(input)
      commands.run(input)
    end
  end
end
