require 'spec_helper'
require 'mtransform/mtransform_dsl'

module Mtransform
  describe MtransformDSL do
    let(:b) do
      proc do
        as_is :b, :c
        rename :a => :x, :d => :y
        set :z => 158
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

      it 'reads set_hash commands from the block' do
        expect(subject.order.select { |x| x.is_a? MtransformDSL::SetHashCommand }.map(&:hash)).to eq [{z: 158}]
      end
    end

    context '#transform' do
      it 'transforms the input hash by running commands read from the block' do
        expect(subject.transform).to eq ({ b: input[:b], c: input[:c], x: input[:a], y: input[:d], z: 158 })
      end

      it 'commands are executed in the order they appear in the block' do
        o = MtransformDSL.new(input) do
          set :c => 155
          rename :a => :c
          as_is :a, :c
        end

        f = MtransformDSL.new(input) do
          set :c => 155
          as_is :a, :c
          rename :a => :c
        end

        z = MtransformDSL.new(input) do
          as_is :a, :c
          rename :a => :c
          set :c => 155
        end

        expect(o.transform).to eq ({a: input[:a], c: input[:c]})
        expect(f.transform).to eq ({a: input[:a], c: input[:a]})
        expect(z.transform).to eq ({a: input[:a], c: 155})
      end
    end

    context 'DSL block' do
      let(:b) do
        proc { }
      end
      let(:input) { { a: 1, b: 5, c: 7, d: -1 } }

      context '#as_is' do
        it 'output values at specified keys will be the values of input at these keys' do
          subject.as_is(:a, :b)
          expect(subject.transform).to eq ({a: input[:a], b: input[:b]})
        end

        it 'raises on non symbol args' do
          expect { subject.as_is(String, Object) }.to raise_error(ArgumentError)
        end
      end

      context '#rename' do
        let(:rename_hash) { {a: :e, b: :g } }

        it 'output value at arg\'s value will be the value of input at arg\'s key' do
          subject.rename(rename_hash)
          expect(subject.transform).to eq ({e: input[:a], g: input[:b]})
        end

        it 'raises on non-hash arg' do
          expect { subject.rename(1) }.to raise_error(ArgumentError)
        end

        it 'raises on a hash arg that doesn\'t implement #keys' do
          h = rename_hash.dup
          h.instance_eval { undef :keys }

          expect { subject.rename(h) }.to raise_error(ArgumentError)
        end

        it 'raises on a hash arg that doesn\'t implement #values' do
          h = rename_hash.dup
          h.instance_eval { undef :values }

          expect { subject.rename(h) }.to raise_error(ArgumentError)
        end

        it 'raises on a hash arg that doesn\'t implement #each' do
          h = rename_hash.dup
          h.instance_eval { undef :each }

          expect { subject.rename(h) }.to raise_error(ArgumentError)
        end

        it 'raises on hash arg that doesn\'t have all #keys and #values to be Symbol' do
          expect { subject.rename(a: String) }.to raise_error(ArgumentError)
        end
      end

      context '#set with a hash argument' do
        let(:set_hash) { {z: 15, w: 'yyy'} }

        it 'output values are copied from the hash arg' do
          subject.set(set_hash)
          expect(subject.transform).to eq set_hash
        end

        it 'raises on a hash arg that doesn\'t implement #keys' do
          h = set_hash.dup
          h.instance_eval { undef :keys }

          expect { subject.set(h) }.to raise_error(ArgumentError)
        end

        it 'raises on a hash arg that doesn\'t implement #each' do
          h = set_hash.dup
          h.instance_eval { undef :each }

          expect { subject.set(h) }.to raise_error(ArgumentError)
        end

        it 'raises on hash arg that doesn\'t have all of its #keys to be Symbol' do
          expect { subject.set(String => 'xxx') }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
