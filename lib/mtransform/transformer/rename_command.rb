module Mtransform
  class Transformer
    class RenameCommand
      attr_reader :hash

      def initialize(hash)
        raise ArgumentError, 'Argument is not a Hash' unless hash.is_a? Hash
        @hash = hash
      end

      def run(input)
        Hash.new.tap do |result|
          hash.each do |from, to|
            result[to] = input[from]
          end
        end
      end
    end
  end
end
