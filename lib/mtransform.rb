require "mtransform/version"
require "mtransform/transformer"

module Mtransform
  extend self

  def transform(hash, context = self, &block)
    Transformer.new(context, &block).transform(hash)
  end
end
