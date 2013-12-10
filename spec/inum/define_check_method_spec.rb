require 'rspec'
require 'spec_helper'

describe Inum::DefineCheckMethod do

  context 'create class after call define_check_method' do
    before(:each) do
      enum = @enum = Class.new(Inum::Base) do
        define_enum :REDBULL,  0
        define_enum :MONSTER,  1
        define_enum :BURN,     2
      end

      @mixin = Class.new do
        attr_accessor :drink

        extend Inum::DefineCheckMethod
        self.define_check_method(:drink, enum)
      end
    end

    it 'defined comparison method.' do
      expect(@mixin.method_defined?(:redbull?)).to be_true
      expect(@mixin.method_defined?(:monster?)).to be_true
      expect(@mixin.method_defined?(:burn?)).to    be_true
    end

    context 'create instance the class,' do
      before(:each) do
        @inst = @mixin.new
      end

      it 'can compare integer.' do
        @inst.drink = 0
        expect(@inst.redbull?).to be_true
        expect(@inst.monster?).to be_false
      end

      it 'can compare string.' do
        @inst.drink = 'REDBULL'
        expect(@inst.redbull?).to be_true
        expect(@inst.monster?).to be_false
      end

      it 'can compare symbol.' do
        @inst.drink = :REDBULL
        expect(@inst.redbull?).to be_true
        expect(@inst.monster?).to be_false
      end

      it 'can compare self instance.' do
        @inst.drink = @enum::REDBULL
        expect(@inst.redbull?).to be_true
        expect(@inst.monster?).to be_false
      end

    end
  end

  context 'create class after call define_check_method with prefix.' do
    before(:each) do
      enum = @enum = Class.new(Inum::Base) do
        define_enum :REDBULL,  0
        define_enum :MONSTER,  1
        define_enum :BURN,     2
      end

      @mixin = Class.new do
        attr_accessor :drink

        extend Inum::DefineCheckMethod
        self.define_check_method(:drink, enum, 'drink_type')
      end
    end

    it 'defined comparison method.' do
      expect(@mixin.method_defined?(:drink_type_redbull?)).to be_true
      expect(@mixin.method_defined?(:drink_type_monster?)).to be_true
      expect(@mixin.method_defined?(:drink_type_burn?)).to    be_true
    end
  end
end
