require "mtransform/version"
require "mtransform/mtransform_dsl"

module Mtransform
  def transform(hash, &block)
    raise ArgumentError unless hash.respond_to?(:[])
    MtransformDSL.new(hash, &block).transform
  end
end
