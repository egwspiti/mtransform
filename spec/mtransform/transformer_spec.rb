require 'spec_helper'
require 'mtransform/transformer'

module Mtransform
  describe Transformer do
    let(:block) do
      proc do
        as_is :b, :c
        rename :a => :x, :d => :y
        set :z => 158
      end
    end
    let(:input) { { a: 1, b: 5, c: 'xxx' } }
    subject { Transformer.new(&block) }

    context '.new' do
      it 'takes a block' do
        expect { Transformer.new(&block) }.not_to raise_error
      end

      it 'takes an optional context argument' do
        context = Object.new
        o = Transformer.new(context, &block)
        expect(o.context).to eq context
      end

      it 'reads as_is commands from the block' do
        expect(subject.commands.commands.select { |x| x.is_a? Transformer::AsIsCommand }.map(&:keys)).to eq [[:b, :c]]
      end

      it 'reads rename commands from the block' do
        expect(subject.commands.commands.select { |x| x.is_a? Transformer::RenameCommand }.map(&:hash)).to eq [{a: :x, d: :y}]
      end

      it 'reads set_hash commands from the block' do
        expect(subject.commands.commands.select { |x| x.is_a? Transformer::SetHashCommand }.map(&:hash)).to eq [{z: 158}]
      end
    end

    context '#transform' do
      it 'transforms the input hash by running commands read from the block' do
        expect(subject.transform(input)).to eq ({ b: input[:b], c: input[:c], x: input[:a], y: input[:d], z: 158 })
      end

      it 'commands are executed in the order they appear in the block' do
        o = Transformer.new do
          set :c => 155
          rename :a => :c
          as_is :a, :c
        end

        f = Transformer.new do
          set :c => 155
          as_is :a, :c
          rename :a => :c
        end

        z = Transformer.new do
          as_is :a, :c
          rename :a => :c
          set :c => 155
        end

        expect(o.transform(input)).to eq ({a: input[:a], c: input[:c]})
        expect(f.transform(input)).to eq ({a: input[:a], c: input[:a]})
        expect(z.transform(input)).to eq ({a: input[:a], c: 155})
      end
    end

    context 'DSL block' do
      let(:block) do
        proc { }
      end
      let(:input) { { a: 1, b: 5, c: 7, d: -1 } }

      context '#as_is' do
        it 'output values at specified keys will be the values of input at these keys' do
          subject.as_is(:a, :b)
          expect(subject.transform(input)).to eq ({a: input[:a], b: input[:b]})
        end

        it 'raises on non symbol args' do
          expect { subject.as_is(String, Object) }.to raise_error(ArgumentError, /not all arguments are symbol/i)
        end
      end

      context '#rename' do
        let(:rename_hash) { {a: :e, b: :g } }

        it 'output value at arg\'s value will be the value of input at arg\'s key' do
          subject.rename(rename_hash)
          expect(subject.transform(input)).to eq ({e: input[:a], g: input[:b]})
        end

        it 'raises on non-hash arg' do
          expect { subject.rename(1) }.to raise_error(ArgumentError, /not a hash/i)
        end

        it 'raises on a hash arg that doesn\'t implement #keys' do
          h = rename_hash.dup
          h.instance_eval { undef :keys }

          expect { subject.rename(h) }.to raise_error(ArgumentError, /implement #keys/)
        end

        it 'raises on a hash arg that doesn\'t implement #values' do
          h = rename_hash.dup
          h.instance_eval { undef :values }

          expect { subject.rename(h) }.to raise_error(ArgumentError, /implement #values/)
        end

        it 'raises on a hash arg that doesn\'t implement #each' do
          h = rename_hash.dup
          h.instance_eval { undef :each }

          expect { subject.rename(h) }.to raise_error(ArgumentError, /implement #each/)
        end

        it 'raises on hash arg that doesn\'t have all #keys and #values to be Symbol' do
          expect { subject.rename(a: String) }.to raise_error(ArgumentError, /not all keys and values are symbol/i )
        end
      end

      context '#set' do
        context 'with a hash argument' do
          let(:set_hash) { {z: 15, w: 'yyy'} }

          it 'output values are copied from the hash arg' do
            subject.set(set_hash)
            expect(subject.transform(input)).to eq set_hash
          end

          it 'raises on a hash arg that doesn\'t implement #keys' do
            h = set_hash.dup
            h.instance_eval { undef :keys }

            expect { subject.set(h) }.to raise_error(ArgumentError, /implement #keys/)
          end

          it 'raises on a hash arg that doesn\'t implement #each' do
            h = set_hash.dup
            h.instance_eval { undef :each }

            expect { subject.set(h) }.to raise_error(ArgumentError, /implement #each/)
          end

          it 'raises on hash arg that doesn\'t have all of its #keys to be Symbol' do
            expect { subject.set(String => 'xxx') }.to raise_error(ArgumentError, /not all keys are symbol/i)
          end
        end

        context 'with a symbol argument' do
          it 'output value at the key pointed by the symbol arg is the result of the evaluation of the block' do
            subject.set(:z) { 1 + 1 }
            expect(subject.transform(input)).to eq ({z: 2})
          end

          it 'the block is evaluated on the context (if any) passed to .new' do
            class TransformWithHelper
              def reverse(str)
                str.reverse
              end
              def transform(input)
                Transformer.new(self) do
                  set :x do |input, _|
                    reverse(input[:a])
                  end
                end.transform(input)
              end
            end
            x = TransformWithHelper.new
            expect(x.transform(a: 'test_abc')).to eq ({x: 'cba_tset'})
          end

          it 'input and output hashes are made available to the block as parameters' do
            subject.set(:f) { 4 }
            subject.set(:z) do |input, output|
              input[:a] + output[:f]
            end
            expect(subject.transform(input)).to eq ({f: 4, z: input[:a] + 4})
          end

          it 'input hash is immutable inside the block' do
            subject.set(:z) do |input, output|
              input[:a] = 15
            end
            expect { subject.transform(input) }.to raise_error(RuntimeError, /can't modify/)
          end

          it 'output hash is immutable inside the block' do
            subject.set(:z) do |input, output|
              output[:a] = 15
            end
            expect { subject.transform(input) }.to raise_error(RuntimeError, /can't modify/)
          end

          it 'gets excecuted after every other command' do
            subject.set(:z) do |input, output|
              input[:a] + output[:f]
            end
            subject.rename(:b => :f)
            expect(subject.transform(input)).to eq ({f: input[:b], z: input[:a] + input[:b]})
          end

          it 'raises when a block is not passed' do
            expect { subject.set(:z) }.to raise_error(ArgumentError, /no block given/i)
          end
        end

        context 'without a symbol or a hash argument' do
          it 'raises' do
            expect { subject.set(1) }.to raise_error(ArgumentError, /no hash or symbol/i)
          end
        end
      end

      context '#rest' do
        context ':keep' do
          it 'copies keys, values from keys that exist in input but not in output' do
            subject.set(:w) { 2 }
            subject.rest(:keep)
            expect(subject.transform(input)).to eq (input.merge(w: 2))
          end

          it 'gets executed after every other command has executed' do
            subject.rest(:keep)
            subject.set(:w) { 2 }
            subject.set(ww: 4)
            expect(subject.transform(input)).to eq (input.merge(w: 2, ww: 4))
          end
        end

        context ':delete' do
          it 'does nothing since the keys to be deleted are not present in output' do
            subject.rest(:delete)
            subject.set(:w) { 2 }
            subject.set(ww: 4)
            expect(subject.transform(input)).to eq ({ w: 2, ww: 4 })
          end

          it 'is the default behaviour of #rest' do
            a = Transformer.new do
              as_is :a, :c
              set :f => 15
              rest :delete
            end

            b = Transformer.new do
              as_is :a, :c
              set :f => 15
            end

            expect(a.transform(input)).to eq (b.transform(input))
          end
        end

        it 'raises when arg is neither :keep or :delete' do
          expect { subject.rest(:xxx) }.to raise_error(ArgumentError, /not a valid action/i)
        end
      end
    end
  end
end
