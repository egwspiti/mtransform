require "mtransform/version"
require "mtransform/mtransform_dsl"

module Mtransform
  def transform(hash, context = self, &block)
    raise ArgumentError unless hash.respond_to?(:[])
    MtransformDSL.new(hash, context, &block).transform
  end
end
