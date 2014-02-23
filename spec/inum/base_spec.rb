require 'rspec'
require 'spec_helper'

describe Inum::Base do

  context 'When define enum,' do
    it 'Correct definition be validation passed.' do
      expect{
        Class.new(Inum::Base) { define :REDBULL,  0 }
        Class.new(Inum::Base) {
          define :REDBULL, 0
          define :MONSTER, 1
        }
      }.not_to raise_error
    end

    it 'Incorrect definition be validation failed.' do
      # wrong name.
      expect{
        Class.new(Inum::Base) { define 1111, 0 }
      }.to raise_error

      # wrong value.
      expect{
        Class.new(Inum::Base) { define :REDBULL, :no_int }
      }.to raise_error

      # dup name.
      expect{
        Class.new(Inum::Base) {
          define :REDBULL, 0
          define :REDBULL, 1
        }
      }.to raise_error

      # dup value.
      expect{
        Class.new(Inum::Base) {
          define :REDBULL, 0
          define :MONSTER, 0
        }
      }.to raise_error
    end

    it 'Autoincrement value when without default value.' do
      enum = Class.new(Inum::Base) do
        define :REDBULL
        define :MONSTER
        define :BURN
      end

      expect(enum::REDBULL.value).to eq(0)
      expect(enum::MONSTER.value).to eq(1)
      expect(enum::BURN.value).to    eq(2)
    end

    it 'Instances of enum are different each definition.' do
      first  = Class.new(Inum::Base){ define :REDBULL }
      second = Class.new(Inum::Base){ define :MONSTER }

      first_enum_format  = first.instance_variable_get(:@enum_format)
      second_enum_format = second.instance_variable_get(:@enum_format)

      first_enums  = first.instance_variable_get(:@enums)
      second_enums = second.instance_variable_get(:@enums)

      expect(first_enum_format.eql?(second_enum_format)).to  be_false
      expect(first_enum_format.equal?(second_enum_format)).to be_false

      expect(first_enums.eql?(second_enums)).to  be_false
      expect(first_enums.equal?(second_enums)).to be_false
    end
  end


  describe 'Defined Inum::Base' do
    before :each do
      class Anime < Inum::Base
        define :NYARUKO,   0
        define :MUROMISAN, 1
        define :NOURIN,    2
        define :KMB,       4
      end
    end

    after :each do
      Object.class_eval{ remove_const :Anime }
    end

    it 'Can not create instance.(Singleton)' do
      expect{ Anime.new(:NICONICO, 2525) }.to raise_error
    end

    it 'The instance of enum is equal.' do
      expect(Anime::NYARUKO.equal?(Anime.parse!('NYARUKO'))).to be_true
    end

    it '<=> method return a correct value.' do
      expect((Anime::MUROMISAN <=> 0)  > 0 ).to be_true
      expect((Anime::MUROMISAN <=> 1) == 0 ).to be_true
      expect((Anime::MUROMISAN <=> 2)  < 0 ).to be_true

      expect(Anime::NYARUKO <=> 'Value can not compare.').to be_nil
    end

    it '+ method return a correct Inum.' do
      expect(Anime::NYARUKO + 1).to eq(Anime::MUROMISAN)
    end

    it '- method return a correct Inum.' do
      expect(Anime::NOURIN - 1).to eq(Anime::MUROMISAN)
    end

    it 'Comparable module enable.' do
      expect(Anime::MUROMISAN.between?(0,2)).to be_true
    end

    it 'each method can execute block with enum' do
      count = 0
      expect{
        Anime.each do |enum|
          expect(enum.instance_of?(Anime)).to be_true
          count += 1
        end
      }.to change{count}.by(Anime.length)
    end

    it 'Enumerable module enable.' do
      expect(Anime.count).to eq(Anime.length)
      expect(Anime.include?(Anime::NOURIN)).to be_true
    end

    it 'eql? method return a correct result.' do
      expect(Anime::KMB.eql?(0) ).to be_false
      expect(Anime::KMB.eql?(4) ).to be_true
    end

    it 'labels method return Array<Symbol>.' do
      expect(Anime.labels.length).to eq(Anime.length)
      expect(Anime.labels.instance_of?(Array)).to     be_true
      expect(Anime.labels[0].instance_of?(Symbol)).to be_true
    end

    it 'length return count of enum.' do
      expect(Anime.length).to eq(4)
    end

    context 'Parse method' do
      it 'Parsable string.' do
        expect(Anime.parse('NOURIN')).to eq(Anime::NOURIN)
      end

      it 'Parsable integer.' do
        expect(Anime.parse(1)).to eq(Anime::MUROMISAN)
      end

      it 'Parsable symbol.' do
        expect(Anime.parse(:KMB)).to eq(Anime::KMB)
      end

      it 'Parsable self instance.' do
        expect(Anime.parse(Anime::NYARUKO)).to eq(Anime::NYARUKO)
      end

      it 'return nil for a unknown value.' do
        expect(Anime.parse('Nothing') ).to eq(nil)
      end

      it 'parse! method raise exception for a unknown value.' do
        expect{Anime.parse!('Nothing') }.to raise_error(NameError)
      end
    end

    it 'to_a method return Array<Enum>.' do
      enums = Anime.instance_variable_get(:@enums)

      expect(Anime.to_a.eql?(enums)).to   be_true
      expect(Anime.to_a.equal?(enums)).to be_false
    end

    it 'to_h method return Hash' do
      enum_format = Anime.instance_variable_get(:@enum_format)

      expect(Anime.to_h.eql?(enum_format)).to   be_true
      expect(Anime.to_h.equal?(enum_format)).to be_false
    end

    it 'to_i and value methods return integer.' do
      expect(Anime::KMB.to_i).to  eq(4)
      expect(Anime::KMB.value).to eq(4)
    end

    it 'to_s method return string.' do
      expect(Anime::NOURIN.to_s ).to eq('NOURIN')
    end

    it 'translate and t methods return localized string.' do
      I18n.should_receive(:t).with('inum.anime.nourin').and_return('のうりん')
      I18n.should_receive(:t).with('inum.anime.kmb').and_return('キルミーベイベー')

      expect(Anime::NOURIN.t).to      eq('のうりん')
      expect(Anime::KMB.translate).to eq('キルミーベイベー')
    end

    it 'underscore method return underscore string.' do
      expect(Anime::NYARUKO.underscore).to eq('nyaruko')
    end

    it 'values method return Array<integer>.' do
      expect(Anime.values.length).to eq(Anime.length)
      expect(Anime.values.instance_of?(Array)).to be_true
      expect(Anime.values[0].integer?).to         be_true
    end
  end
end
