require 'spec_helper'

describe SimpleSet do
  it 'should raise on error when manipulating invalid values' do
    named_model('TestExceptions') do
      as_set :values, [:a, :b]
    end

    sample = TestExceptions.new
    expect { sample.values = [:a] }.to_not raise_error
    expect { sample.values = [:b] }.to_not raise_error
    expect { sample.values = [:c] }.to raise_error(ArgumentError)
  end

  it 'should accept an array of symbols' do
    named_model('InitWithArrayOfSymbol') do
      as_set :values, [:a, :b, :c, :d, :e, :f]
    end

    expect(InitWithArrayOfSymbol.a).to eq(1)
    expect(InitWithArrayOfSymbol.b).to eq(2)
    expect(InitWithArrayOfSymbol.c).to eq(4)
    expect(InitWithArrayOfSymbol.d).to eq(8)
    expect(InitWithArrayOfSymbol.e).to eq(16)
    expect(InitWithArrayOfSymbol.f).to eq(32)
  end

  it 'should accept a hash' do
    named_model('InitWithHash') do
      as_set :values, { a: 1, b: 2, c: 4, d: 8, all: 15 }
    end

    expect(InitWithHash.a).to eq(1)
    expect(InitWithHash.b).to eq(2)
    expect(InitWithHash.c).to eq(4)
    expect(InitWithHash.d).to eq(8)
    expect(InitWithHash.all).to eq(15)

    sample = InitWithHash.new
    sample.all = true
    expect(sample.a?).to be_truthy
    expect(sample.b?).to be_truthy
    expect(sample.c?).to be_truthy
    expect(sample.d?).to be_truthy
    expect(sample.all?).to be_truthy
    sample.b = false
    expect(sample.all?).to be_falsey
    sample.b = true
    expect(sample.all?).to be_truthy
  end

  it 'should distinguish nil from empty set' do
    named_model('NilOrEmpty') do
      as_set :values, [:a, :b]
    end

    sample = NilOrEmpty.new

    expect(sample.a?).to be_falsey
    expect(sample.b?).to be_falsey
    expect(sample.values_cd).to eq(nil)
    expect(sample.values).to eq(nil)

    sample.values = [:a]
    expect(sample.values).to eq([:a])
    sample.values = nil
    expect(sample.values).to eq(nil)

    sample.a = true
    expect(sample.values).to eq([:a])
    sample.a = false
    expect(sample.values).to eq([])

    sample.values = nil
    expect(sample.values).to eq(nil)
    sample.a = false
    expect(sample.values).to eq([])
  end

  it 'should support fields with a default value' do
    named_model('FieldWithDefaultValue') do
      as_set :values_with_default, [:x, :y]
    end

    sample = FieldWithDefaultValue.new
    expect(sample.values_with_default_cd).to eq(2)
    expect(sample.values_with_default).to eq([:y])

    sample.values_with_default = nil
    expect(sample.values_with_default).to eq(nil)
  end

  it 'should work outside activerecord' do
    class FruitsEater
      include SimpleSet
      as_set :fruits_i_like, [:apples, :bananas, :pinaple]
      attr_accessor :fruits_i_like_cd
    end

    sample = FruitsEater.new
    sample.fruits_i_like = [:apples, :pinaple]
    expect(sample.fruits_i_like_cd).to eq(5)
  end

  it 'should return acceptable values' do
    named_model('AcceptableValues') do
      as_set :spoken_languages, [:english, :french, :german, :japanese]
    end

    expect(AcceptableValues.spoken_languages).to eq([:english, :french, :german, :japanese])
  end

  it 'should support Rails assignment' do
    named_model('User') do
      as_set :values, [:foo_manager, :bar_manager, :baz_manager]
    end

    sample = User.new
    sample.values = ["foo_manager", "baz_manager", ""]
    expect(sample.values).to eq([:foo_manager, :baz_manager])
  end

  #   ___        _   _
  #  / _ \ _ __ | |_(_) ___  _ __  ___
  # | | | | '_ \| __| |/ _ \| '_ \/ __|
  # | |_| | |_) | |_| | (_) | | | \__ \
  #  \___/| .__/ \__|_|\___/|_| |_|___/
  #       |_|

  describe 'options' do

    #  _        _
    # (_)__ ___| |_  _ _ __  _ _
    #  _/ _/ _ \ | || | '  \| ' \
    # (_)__\___/_|\_,_|_|_|_|_||_|
    #

    describe ":column" do
      it 'should support a custom column name' do
        named_model('TestOptionColumn1') do
          as_set :languages, [:english, :french, :german, :japanese], column: 'custom_name'
        end

        sample = TestOptionColumn1.new
        sample.languages = [:french, :german]
        expect(sample.english?).to be_falsey
        expect(sample.french?).to be_truthy
        expect(sample.german?).to be_truthy
        expect(sample.japanese?).to be_falsey
        expect(sample.custom_name).to eq(6)
      end
    end

    #  _               __ _
    # (_)_ __ _ _ ___ / _(_)_ __
    #  _| '_ \ '_/ -_)  _| \ \ /
    # (_) .__/_| \___|_| |_/_\_\
    #   |_|

    describe ':prefix' do
      it "should support automatic prefix in getters and setters" do
        named_model('TestOptionPrefix1') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], prefix: true
        end

        sample = TestOptionPrefix1.new
        expect(sample).to respond_to(:spoken_language_english?)
        expect(sample).to respond_to(:spoken_language_french?)
        expect(sample).to respond_to(:spoken_language_german?)
        expect(sample).to respond_to(:spoken_language_japanese?)

        expect(sample).to respond_to(:spoken_language_english=)
        expect(sample).to respond_to(:spoken_language_french=)
        expect(sample).to respond_to(:spoken_language_german=)
        expect(sample).to respond_to(:spoken_language_japanese=)

        expect(TestOptionPrefix1).to respond_to(:spoken_language_english)
        expect(TestOptionPrefix1).to respond_to(:spoken_language_french)
        expect(TestOptionPrefix1).to respond_to(:spoken_language_german)
        expect(TestOptionPrefix1).to respond_to(:spoken_language_japanese)

        expect(sample).to_not respond_to(:japanese?)
      end

      it "should support custom prefix in getters and setters" do
        named_model('TestOptionPrefix2') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], prefix: 'speaks'
        end

        sample = TestOptionPrefix2.new
        expect(sample).to respond_to(:speaks_english?)
        expect(sample).to respond_to(:speaks_french?)
        expect(sample).to respond_to(:speaks_german?)
        expect(sample).to respond_to(:speaks_japanese?)

        expect(sample).to respond_to(:speaks_english=)
        expect(sample).to respond_to(:speaks_french=)
        expect(sample).to respond_to(:speaks_german=)
        expect(sample).to respond_to(:speaks_japanese=)

        expect(TestOptionPrefix2).to respond_to(:speaks_english)
        expect(TestOptionPrefix2).to respond_to(:speaks_french)
        expect(TestOptionPrefix2).to respond_to(:speaks_german)
        expect(TestOptionPrefix2).to respond_to(:speaks_japanese)

        expect(sample).to_not respond_to(:japanese?)
      end
    end

    #  _    _ _
    # (_)__| (_)_ __
    #  _(_-< | | '  \
    # (_)__/_|_|_|_|_|
    #

    describe ":slim" do
      it 'should not generate instance nor class members when true is passed' do
        named_model('TestOptionSlim1') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], slim: true
        end

        expect(TestOptionSlim1).to_not respond_to(:english)
        expect(TestOptionSlim1).to_not respond_to(:french)
        expect(TestOptionSlim1).to_not respond_to(:german)
        expect(TestOptionSlim1).to_not respond_to(:japanese)

        sample = TestOptionSlim1.new
        expect(sample).to_not respond_to(:english?)
        expect(sample).to_not respond_to(:french?)
        expect(sample).to_not respond_to(:german?)
        expect(sample).to_not respond_to(:japanese?)

        expect(sample).to_not respond_to(:english=)
        expect(sample).to_not respond_to(:french=)
        expect(sample).to_not respond_to(:german=)
        expect(sample).to_not respond_to(:japanese=)
      end

      it 'should only generate instance members when :class is passed' do
        named_model('TestOptionSlim2') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], slim: :class
        end

        expect(TestOptionSlim2).to_not respond_to(:english)
        expect(TestOptionSlim2).to_not respond_to(:french)
        expect(TestOptionSlim2).to_not respond_to(:german)
        expect(TestOptionSlim2).to_not respond_to(:japanese)

        sample = TestOptionSlim2.new
        expect(sample).to respond_to(:english?)
        expect(sample).to respond_to(:french?)
        expect(sample).to respond_to(:german?)
        expect(sample).to respond_to(:japanese?)

        expect(sample).to respond_to(:english=)
        expect(sample).to respond_to(:french=)
        expect(sample).to respond_to(:german=)
        expect(sample).to respond_to(:japanese=)
      end
    end

    #  _        _    _
    # (_)_ __ _| |_ (_)_ _ _  _
    #  _\ V  V / ' \| | ' \ || |
    # (_)\_/\_/|_||_|_|_||_\_, |
    #                      |__/

    describe ':whiny' do
      it 'should not raise exception on invalid value' do
        named_model('TestOptionWhiny1') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], whiny: false
        end

        sample = TestOptionWhiny1.new
        expect { sample.spoken_languages = [:french, :italian, :japanese] }.to_not raise_error
        expect(sample.spoken_languages).to eq([:french, :japanese])
      end
    end
  end
end
