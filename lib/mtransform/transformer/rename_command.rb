module Mtransform
  class Transformer
    class RenameCommand
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def run(input)
        {}.tap do |result|
          hash.each do |from, to|
            result[to] = input[from]
          end
        end
      end
    end
  end
end
