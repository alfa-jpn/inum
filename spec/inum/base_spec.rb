require 'rspec'
require 'spec_helper'

describe Inum::Base do

  context 'define class of extended Inum::Base,' do
    before(:each) do
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

    it 'when call to_i of enum, return integer.' do
      expect( @enum::REDBULL.to_i ).to eq(0)
    end

    it 'when call to_s of enum, return string.' do
      expect( @enum::MONSTER.to_s ).to eq('MONSTER')
    end

    it 'can parse from string.' do
      expect( @enum::parse('REDBULL') ).to eq( @enum::REDBULL )
    end

    it 'can parse from integer.' do
      expect( @enum::parse(1) ).to eq( @enum::MONSTER )
    end

    it 'can parse from symbol.' do
      expect( @enum::parse(:BURN) ).to eq( @enum::BURN )
    end

    it 'can parse from self instance.' do
      expect( @enum::parse(@enum::REDBULL) ).to eq( @enum::REDBULL )
    end

  end

end