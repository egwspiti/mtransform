require "mtransform/version"
require "mtransform/transformer"

module Mtransform
  def transform(hash, context = self, &block)
    raise ArgumentError unless hash.respond_to?(:[])
    Transformer.new(hash, context, &block).transform
  end
end
