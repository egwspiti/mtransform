require "mtransform/version"
require "mtransform/mtransform_dsl"

module Mtransform
  def transform(hash, &b)
    raise ArgumentError unless hash.respond_to?(:[])
    MtransformDSL.new(hash, &b).transform
  end
end
