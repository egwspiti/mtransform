require 'mtransform/mtransform_dsl/as_is_command'
require 'mtransform/mtransform_dsl/rename_command'
require 'mtransform/mtransform_dsl/set_hash_command'
require 'mtransform/mtransform_dsl/set_proc_command'

module Mtransform
  class MtransformDSL
    attr_reader :input, :output, :order

    def initialize(hash, &b)
      @input  = hash
      @output = {}
      @order = []
      instance_eval(&b)
    end

    def as_is(*keys)
      order << AsIsCommand.new(keys)
    end

    def rename(hash)
      order << RenameCommand.new(hash)
    end

    def set(arg, &block)
      case arg
      when Hash
        order << SetHashCommand.new(arg)
      when Symbol
        order << SetProcCommand.new(arg, &block)
      else
        raise ArgumentError
      end
    end

    def transform
      order.map do |cmd|
        cmd.run(input)
      end.inject(&:merge)
    end
  end
end
