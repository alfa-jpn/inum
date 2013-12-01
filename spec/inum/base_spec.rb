require 'rspec'
require 'spec_helper'

describe Inum::Base do

  it 'define_enum validate correct' do
    # correct.
    expect{
      Class.new(Inum::Base) { define_enum :REDBULL,  0 }
      Class.new(Inum::Base) { define_enum :REDBULL,  0.to_i }
      Class.new(Inum::Base) {
        define_enum :REDBULL, 0
        define_enum :MONSTER, 1
      }
    }.not_to raise_error

    # wrong name.
    expect{
      Class.new(Inum::Base) { define_enum 1111, 0 }
    }.to raise_error

    # wrong value.
    expect{
      Class.new(Inum::Base) { define_enum :REDBULL, :no_int }
    }.to raise_error

    # dup name.
    expect{
      Class.new(Inum::Base) {
        define_enum :REDBULL, 0
        define_enum :REDBULL, 1
      }
    }.to raise_error

    # dup value.
    expect{
      Class.new(Inum::Base) {
        define_enum :REDBULL,  0
        define_enum :REDBULL2, 0
      }
    }.to raise_error
  end

  it 'define_enum called without value, value is autoincrement.' do
    enum = Class.new(Inum::Base) do
      define_enum :REDBULL
      define_enum :MONSTER
      define_enum :BURN
    end

    expect(enum::REDBULL.to_i).to eq(0)
    expect(enum::MONSTER.to_i).to eq(1)
    expect(enum::BURN.to_i).to    eq(2)
  end

  it 'i18n.t called when call define_enum.' do
    I18n.should_receive(:t).with('hoge.redbull')

    class Hoge < Inum::Base
      define_enum :REDBULL
    end
  end

  context 'define class of extended Inum::Base,' do
    before(:each) do
      I18n.stub(:t).and_return('Good drink!')
      @enum = Class.new(Inum::Base) do
        define_enum :REDBULL,  0
        define_enum :MONSTER,  1
        define_enum :BURN,     2
      end
    end

    it 'can not call new.' do
      expect{ @enum.new(1) }.to raise_error
    end

    it 'DEFINED_ENUM is different instance.' do
      @enum2 = Class.new(Inum::Base) do
        define_enum :REDBULL,  0
      end
      expect( @enum::DEFINED_ENUMS.equal?(@enum2::DEFINED_ENUMS) ).to be_false
    end

    it 'A enum instance is equal instance.' do
      expect( @enum::BURN.equal?(@enum::BURN )).to be_true
    end

    it '<=> return a correct value.' do
      expect( (@enum::REDBULL <=> 1) < 0 ).to be_true
      expect( (@enum::REDBULL <=> 0) == 0 ).to be_true
      expect( (@enum::MONSTER <=> 0) > 0 ).to be_true
    end

    it '+ return a correct Inum.' do
      expect(@enum::REDBULL + 1).to eq(@enum::MONSTER)
      expect(@enum::REDBULL + @enum::MONSTER).to eq(@enum::MONSTER)
    end

    it '- return a correct Inum.' do
      expect(@enum::BURN - 1).to eq(@enum::MONSTER)
      expect(@enum::BURN - @enum::MONSTER).to eq(@enum::MONSTER)
    end

    it 'Comparable module enable.' do
      expect(@enum::REDBULL.between?(0,1)).to be_true
    end

    it 'eql? return a correct result.' do
      expect( @enum::REDBULL.eql?(0) ).to be_true
      expect( @enum::REDBULL.eql?(1) ).to be_false
    end

    it 'to_i return integer.' do
      expect( @enum::REDBULL.to_i ).to eq(0)
    end

    it 'to_s return string.' do
      expect( @enum::MONSTER.to_s ).to eq('MONSTER')
    end

    it 'to_t return localized string.' do
      expect( @enum::REDBULL.to_t ).to eq('Good drink!')
    end

    it 'to_u return underscore string.' do
      expect( @enum::REDBULL.to_u ).to eq('redbull')
    end

    it 'each can execute block with enum' do
      count = 0
      expect{
        @enum::each do |enum|
          expect(enum.instance_of?(@enum)).to be_true
          count += 1
        end
      }.to change{count}.by(3)
    end

    it 'Enumerable module enable.' do
      expect(@enum::count).to eq(3)
      expect(@enum::include?(@enum::REDBULL)).to be_true
    end

    it 'labels return Array<Symbol>.' do
      expect(@enum::labels.length).to eq(3)
      expect(@enum::labels.instance_of?(Array)).to     be_true
      expect(@enum::labels[0].instance_of?(Symbol)).to be_true
    end

    it 'length return count of enum.' do
      expect(@enum::length).to eq(3)
    end

    it 'to_a return Array<Array<Symbol,Integer>>.' do
      expect(@enum::to_a.length).to eq(3)
      expect(@enum::to_a.instance_of?(Array)).to        be_true
      expect(@enum::to_a[0].instance_of?(Array)).to     be_true
      expect(@enum::to_a[0][0].instance_of?(Symbol)).to be_true
      expect(@enum::to_a[0][1].integer?).to             be_true

      expect(@enum::to_a[0][0]).to eq(:REDBULL)
      (0..2).each{|i| expect(@enum::to_a[i][1]).to eq(i) }
    end

    it 'to_h return Hash' do
      expect(@enum::to_h.instance_of?(Hash)).to be_true
      expect(@enum::to_h.eql?(@enum::DEFINED_ENUMS)).to be_true
      expect(@enum::to_h.equal?(@enum::DEFINED_ENUMS)).to be_false
    end

    it 'parse return instance from string.' do
      expect( @enum::parse('REDBULL') ).to eq( @enum::REDBULL )
    end

    it 'parse return instance from integer.' do
      expect( @enum::parse(1) ).to eq( @enum::MONSTER )
    end

    it 'parse return instance from symbol.' do
      expect( @enum::parse(:BURN) ).to eq( @enum::BURN )
    end

    it 'parse return instance from self instance.' do
      expect( @enum::parse(@enum::REDBULL) ).to eq( @enum::REDBULL )
    end

    it 'values return Array<Integer>.' do
      expect(@enum::values.length).to eq(3)
      expect(@enum::values.instance_of?(Array)).to be_true
      expect(@enum::values[0].integer?).to         be_true
    end
  end
end
