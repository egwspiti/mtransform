# Mtransform
version 0.0.1

## About
Mtransform is a dsl for manipulating keys and values of Hashes. The keys should be symbols.

## Installation
Add `gem 'mtransform', github: 'egwspiti/mtransform'` to your Gemfile.

## Usage
There are 3 ways to use this dsl:

* Directly use `Mtransform::transform` passing it the hash to be manipulated and a DSL block:

    ```
    require 'mtransform'

    z = Mtransform::transform(a: 3, b: -2, c: 'xxx', d: '') do
      as_is :f, :g
      rename :a => :aa
      set :z => 'Hello'
      set :b do |input, _|
        input[:b] > 0 ? 'positive' : 'negative'
      end
      set :a do |input, _|
        input[:a] * input[:b]
      end
      set(:w) { |_, output| output[:a] * 25 }
    end
    ```
* Include `Mtransform` in a class and then use the provided `transform` method passing it the hash to be manipulated and a dsl block:

    ```
    require 'mtransform'

    class MyTransform
      include Mtransform

      def multiply(a, b)
        a * b
      end

      def formula(a)
        a * 25
      end

      def run(input)
        transform(input) do
          as_is :f, :g
          rename :a => :aa
          set :z => 'Hello'
          set :b do |input, _|
            input[:b] > 0 ? 'positive' : 'negative'
          end
          set :a do |input, _|
            multiply(input[:a], input[:b])
          end
          set(:w) { |_, output| formula(output[:a]) }
        end
      end
    end

    z = MyTransform.new.run(a: 3, b: -2, c: 'xxx', d: '')
    ```

* Create an `Mtransform::Transformer` object passing it the DSL block and then invoke `transform` on it passing it the hash to be manipulated:

    ```
    require 'mtransform'

    transformer = Mtransform::Transformer.new do
      as_is :f, :g
      rename :a => :aa
      set :z => 'Hello'
      set :b do |input, _|
        input[:b] > 0 ? 'positive' : 'negative'
      end
      set :a do |input, _|
        input[:a] * input[:b]
      end
      set(:w) { |_, output| output[:a] * 25 }
    end

    z = transformer.transform(a: 3, b: -2, c: 'xxx', d: '')
    ```

## DSL Commands
#### as_is

Specify which keys should appear in the output hash without any modification of either the key or its value.

#### rename

Specify keys to be renamed in the output hash. Only the keys are renamed. It accepts a hash argument whose keys are the inputs keys and values are the desired output keys.

#### set

set command has two forms, one accepting a hash argument and another one accepting a symbol argument and a block:

  * Hash argument

  The key of the hash refers to a key into the output hash, while the value of hash is the desired value for that key.

  * Symbol argument and block

  The symbol refers to a key into the output hash. The value of that key will be the value returned by the evaluation of the supplied block.

#### rest

By default, all the keys that aren't set by the dsl are discarded. Pass `:keep` to rest in order to copy them into the output hash.

## Contributing

1. Fork it ( http://github.com/egwspiti/mtransform/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
