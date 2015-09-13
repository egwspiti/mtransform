require 'spec_helper'
require 'mtransform/mtransform_dsl'

module Mtransform
  describe MtransformDSL do
    let(:b) do
      proc do
        as_is :b, :c
        rename :a => :x, :d => :y
      end
    end
    let(:input) { { a: 1, b: 5, c: 'xxx' } }
    subject { MtransformDSL.new(input, &b) }

    context '.new' do
      it 'takes a hash and a block' do
        o = MtransformDSL.new(input, &b)
        expect(o.input).to eq input
      end

      it 'reads as_is commands from the block' do
        expect(subject.order.select { |x| x.is_a? MtransformDSL::AsIsCommand }.map(&:keys)).to eq [[:b, :c]]
      end

      it 'reads rename commands from the block' do
        expect(subject.order.select { |x| x.is_a? MtransformDSL::RenameCommand }.map(&:hash)).to eq [{a: :x, d: :y}]
      end
    end

    context '#transform' do
      it 'transforms the input hash by running commands read from the block' do
        expect(subject.transform).to eq ({ b: input[:b], c: input[:c], x: input[:a], y: input[:d] })
      end

      it 'commands are executed in the order they appear in the block' do
        o = MtransformDSL.new(input) do
          rename :a => :c
          as_is :a, :c
        end

        f = MtransformDSL.new(input) do
          as_is :a, :c
          rename :a => :c
        end

        expect(o.transform).to eq ({a: input[:a], c: input[:c]})
        expect(f.transform).to eq ({a: input[:a], c: input[:a]})
      end
    end

    context 'DSL block' do
      let(:b) do
        proc { }
      end
      let(:input) { { a: 1, b: 5, c: 7, d: -1 } }

      context '#as_is' do

        it 'raises on non symbol args' do
          expect { subject.as_is(String, Object) }.to raise_error(ArgumentError)
        end

        it 'output values at specified keys will be the values of input at these keys' do
          subject.as_is(:a, :b)
          expect(subject.transform).to eq ({a: input[:a], b: input[:b]})
        end
      end

      context '#rename' do
        let(:rename_hash) { {a: :e, b: :g } }

        it 'raises on args that don\'t implement #keys' do
          h = rename_hash.dup
          h.instance_eval { undef :keys }

          expect { subject.rename(h) }.to raise_error(ArgumentError)
        end

        it 'raises on args that don\'t implement #values' do
          h = rename_hash.dup
          h.instance_eval { undef :values }

          expect { subject.rename(h) }.to raise_error(ArgumentError)
        end

        it 'raises on args that don\'t have all #keys and #values to be Symbol' do
          expect { subject.rename(a: String) }.to raise_error(ArgumentError)
        end

        it 'output value at arg\'s value will be the value of input at arg\'s key' do
          subject.rename(rename_hash)
          expect(subject.transform).to eq ({e: input[:a], g: input[:b]})
        end
      end
    end
  end
end
