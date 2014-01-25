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

    InitWithArrayOfSymbol.a.should == 1
    InitWithArrayOfSymbol.b.should == 2
    InitWithArrayOfSymbol.c.should == 4
    InitWithArrayOfSymbol.d.should == 8
    InitWithArrayOfSymbol.e.should == 16
    InitWithArrayOfSymbol.f.should == 32
  end

  it 'should accept a hash' do
    named_model('InitWithHash') do
      as_set :values, { a: 1, b: 2, c: 4, d: 8, all: 15 }
    end

    InitWithHash.a.should == 1
    InitWithHash.b.should == 2
    InitWithHash.c.should == 4
    InitWithHash.d.should == 8
    InitWithHash.all.should == 15

    sample = InitWithHash.new
    sample.all = true
    sample.a?.should be_true
    sample.b?.should be_true
    sample.c?.should be_true
    sample.d?.should be_true
    sample.all?.should be_true
    sample.b = false
    sample.all?.should be_false
    sample.b = true
    sample.all?.should be_true
  end

  it 'should distinguish nil from empty set' do
    named_model('NilOrEmpty') do
      as_set :values, [:a, :b]
    end

    sample = NilOrEmpty.new

    sample.a?.should be_false
    sample.b?.should be_false
    sample.values_cd.should == nil
    sample.values.should == nil

    sample.values = [:a]
    sample.values.should == [:a]
    sample.values = nil
    sample.values.should == nil

    sample.a = true
    sample.values.should == [:a]
    sample.a = false
    sample.values.should == []

    sample.values = nil
    sample.values.should == nil
    sample.a = false
    sample.values.should == []
  end

  it 'should support fields with a default value' do
    named_model('FieldWithDefaultValue') do
      as_set :values_with_default, [:x, :y]
    end

    sample = FieldWithDefaultValue.new
    sample.values_with_default_cd.should == 2
    sample.values_with_default.should == [:y]

    sample.values_with_default = nil
    sample.values_with_default.should == nil
  end

  it 'should work outside activerecord' do
    class FruitsEater
      include SimpleSet
      as_set :fruits_i_like, [:apples, :bananas, :pinaple]
      attr_accessor :fruits_i_like_cd
    end

    sample = FruitsEater.new
    sample.fruits_i_like = [:apples, :pinaple]
    sample.fruits_i_like_cd.should == 5
  end

  it 'should return acceptable values' do
    named_model('AcceptableValues') do
      as_set :spoken_languages, [:english, :french, :german, :japanese]
    end

    AcceptableValues.spoken_languages.should == [:english, :french, :german, :japanese]
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
        sample.english?.should be_false
        sample.french?.should be_true
        sample.german?.should be_true
        sample.japanese?.should be_false
        sample.custom_name.should == 6
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
        sample.should respond_to(:spoken_languages_english?)
        sample.should respond_to(:spoken_languages_french?)
        sample.should respond_to(:spoken_languages_german?)
        sample.should respond_to(:spoken_languages_japanese?)

        sample.should respond_to(:spoken_languages_english=)
        sample.should respond_to(:spoken_languages_french=)
        sample.should respond_to(:spoken_languages_german=)
        sample.should respond_to(:spoken_languages_japanese=)

        TestOptionPrefix1.should respond_to(:spoken_languages_english)
        TestOptionPrefix1.should respond_to(:spoken_languages_french)
        TestOptionPrefix1.should respond_to(:spoken_languages_german)
        TestOptionPrefix1.should respond_to(:spoken_languages_japanese)

        sample.should_not respond_to(:japanese?)
      end

      it "should support custom prefix in getters and setters" do
        named_model('TestOptionPrefix2') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], prefix: 'speaks'
        end

        sample = TestOptionPrefix2.new
        sample.should respond_to(:speaks_english?)
        sample.should respond_to(:speaks_french?)
        sample.should respond_to(:speaks_german?)
        sample.should respond_to(:speaks_japanese?)

        sample.should respond_to(:speaks_english=)
        sample.should respond_to(:speaks_french=)
        sample.should respond_to(:speaks_german=)
        sample.should respond_to(:speaks_japanese=)

        TestOptionPrefix2.should respond_to(:speaks_english)
        TestOptionPrefix2.should respond_to(:speaks_french)
        TestOptionPrefix2.should respond_to(:speaks_german)
        TestOptionPrefix2.should respond_to(:speaks_japanese)

        sample.should_not respond_to(:japanese?)
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

        TestOptionSlim1.should_not respond_to(:english)
        TestOptionSlim1.should_not respond_to(:french)
        TestOptionSlim1.should_not respond_to(:german)
        TestOptionSlim1.should_not respond_to(:japanese)

        sample = TestOptionSlim1.new
        sample.should_not respond_to(:english?)
        sample.should_not respond_to(:french?)
        sample.should_not respond_to(:german?)
        sample.should_not respond_to(:japanese?)

        sample.should_not respond_to(:english=)
        sample.should_not respond_to(:french=)
        sample.should_not respond_to(:german=)
        sample.should_not respond_to(:japanese=)
      end

      it 'should only generate instance members when :class is passed' do
        named_model('TestOptionSlim2') do
          as_set :spoken_languages, [:english, :french, :german, :japanese], slim: :class
        end

        TestOptionSlim2.should_not respond_to(:english)
        TestOptionSlim2.should_not respond_to(:french)
        TestOptionSlim2.should_not respond_to(:german)
        TestOptionSlim2.should_not respond_to(:japanese)

        sample = TestOptionSlim2.new
        sample.should respond_to(:english?)
        sample.should respond_to(:french?)
        sample.should respond_to(:german?)
        sample.should respond_to(:japanese?)

        sample.should respond_to(:english=)
        sample.should respond_to(:french=)
        sample.should respond_to(:german=)
        sample.should respond_to(:japanese=)
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
        sample.spoken_languages.should == [:french, :japanese]
      end
    end
  end
end
