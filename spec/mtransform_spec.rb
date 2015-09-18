require 'spec_helper'
require 'mtransform'

describe Mtransform do
  let(:klass) { Class.new { include Mtransform } }

  it 'provides #transform when included' do
    obj = klass.new
    expect(obj).to respond_to(:transform)
  end

  context '#transform' do
    let(:obj) { klass.new }
    let(:hash) { {a: 1, b: 5} }

    it 'creates a new Transformer object' do
      expect(Mtransform::Transformer).to receive(:new).with(hash, obj).and_call_original
      obj.transform(hash) do

      end
    end

    it 'invokes #transform on the created Transformer object' do
      expect(Mtransform::Transformer).to receive(:new).with(hash, obj).and_return(object = Object.new)
      expect(object).to receive(:transform)
      obj.transform(hash) do

      end
    end

    it 'raises ArgumentError on argument that doesn\'t implement #[]' do
      h = hash.dup
      h.instance_eval { undef :[] }
      expect { obj.transform(h) }.to raise_error(ArgumentError)
    end

    it 'accepts an optional context argument' do
      x = Object.new
      expect(Mtransform::Transformer).to receive(:new).with(hash, x).and_call_original
      obj.transform(hash, x) do

      end
    end
  end
end

