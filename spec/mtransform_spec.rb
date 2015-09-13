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

    it 'raises ArgumentError on argument that doesn\'t implement #[]' do
      h = hash.dup
      h.instance_eval { undef :[] }
      expect { obj.transform(h) }.to raise_error(ArgumentError)
    end

    it 'creates a new MtransformDSL object' do
      expect(Mtransform::MtransformDSL).to receive(:new).with(hash).and_call_original
      obj.transform(hash) do

      end
    end

    it 'invokes #transform on the created MtransformDSL object' do
      expect(Mtransform::MtransformDSL).to receive(:new).with(hash).and_return(object = Object.new)
      expect(object).to receive(:transform)
      obj.transform(hash) do

      end
    end
  end
end

