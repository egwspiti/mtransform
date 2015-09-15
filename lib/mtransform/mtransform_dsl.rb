require 'mtransform/mtransform_dsl/as_is_command'
require 'mtransform/mtransform_dsl/rename_command'
require 'mtransform/mtransform_dsl/set_hash_command'
require 'mtransform/mtransform_dsl/set_proc_command'

module Mtransform
  class MtransformDSL
    attr_reader :input, :output, :commands

    def initialize(hash, &block)
      @input  = hash
      @output = {}
      @commands = []
      instance_eval(&block)
    end

    def as_is(*keys)
      commands << AsIsCommand.new(keys)
    end

    def rename(hash)
      commands << RenameCommand.new(hash)
    end

    def set(arg, &block)
      case arg
      when Hash
        commands << SetHashCommand.new(arg)
      when Symbol
        commands << SetProcCommand.new(arg, &block)
      else
        raise ArgumentError
      end
    end

    def transform
      commands.map do |command|
        command.run(input)
      end.inject(&:merge)
    end
  end
end
