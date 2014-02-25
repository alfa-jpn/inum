require 'rspec'
require 'spec_helper'

describe Inum::ActiveRecordMixin do
  create_temp_table(:tvs){|t| t.integer :anime; t.integer :favorite; t.integer :watching}

  before :each do
    class Anime < Inum::Base
      define :NYARUKO,   0
      define :MUROMISAN, 1
      define :NOURIN,    2
      define :KMB,       4
    end

    class TV < ActiveRecord::Base
      bind_inum :column => :anime, :class => Anime

      bind_inum :column => :favorite, :class => Anime, :prefix => :fav, :allow_nil => true

      bind_inum :column => :watching, :class => Anime, :prefix => nil,  :validation => false
    end
  end

  after :each do
    Object.class_eval do
      remove_const :TV
      remove_const :Anime
    end
  end

  let :tv do
    TV.create(anime: Anime::NYARUKO)
  end

  context 'Comparison methods' do
    it 'Be defined' do
      expect(TV.method_defined?(:anime_nyaruko?)).to   be_true
      expect(TV.method_defined?(:anime_muromisan?)).to be_true
      expect(TV.method_defined?(:anime_nourin?)).to    be_true
      expect(TV.method_defined?(:anime_kmb?)).to       be_true
    end

    it 'Can compare' do
      expect(tv.anime_nyaruko?).to be_true
    end
  end

  context 'getter' do
    it 'Can set enum' do
      tv.anime = Anime::NOURIN
      expect(tv.anime_nourin?).to be_true
    end

    it 'Can set integer' do
      tv.anime = 1
      expect(tv.anime_muromisan?).to be_true
    end

    it 'Can set string' do
      tv.anime = 'KMB'
      expect(tv.anime_kmb?).to be_true
    end

    it 'Can set symbol' do
      tv.anime = :KMB
      expect(tv.anime_kmb?).to be_true
    end
  end

  it 'Prefix is enable, when prefix was set.' do
      expect(TV.method_defined?(:fav_nyaruko?)).to   be_true
      expect(TV.method_defined?(:fav_muromisan?)).to be_true
      expect(TV.method_defined?(:fav_nourin?)).to    be_true
      expect(TV.method_defined?(:fav_kmb?)).to       be_true
  end

  it 'Prefix is nothing, when prefix is nil.' do
      expect(TV.method_defined?(:nyaruko?)).to   be_true
      expect(TV.method_defined?(:muromisan?)).to be_true
      expect(TV.method_defined?(:nourin?)).to    be_true
      expect(TV.method_defined?(:kmb?)).to       be_true
  end

  it 'setter return enum' do
    expect(tv.anime.instance_of?(Anime)).to be_true
  end

  context 'update methods can update enum column' do
    it 'update' do
      tv.update!(anime: Anime::NOURIN)
      expect(tv.reload.anime).to eq(Anime::NOURIN)
    end

    it 'update_attribute' do
      tv.update_attribute(:anime, Anime::NOURIN)
      expect(tv.reload.anime).to eq(Anime::NOURIN)
    end
  end

  context 'validation' do
    let :validators do
      TV.validators.map{|v| v.attributes[0]}
    end

    it 'Enable validator' do
      expect(validators).to include(:anime)
      expect(validators).to include(:favorite)
    end

    it 'Disable validator when column has option of validation false.' do
      expect(validators).not_to include(:watching)
    end

    context 'valid' do
      it 'default is validation passed.' do
        expect(tv).to be_valid
      end

      it 'Correct values are validation passed.' do
        Anime.each do |enum|
          tv.anime = enum
          expect(tv).to be_valid
        end
      end

      it 'Incorrect values are validation failed.' do
        [-1000, 9999, 'Nothing!!', :Nothing].each do |value|
          tv.anime = value
          expect(tv).not_to be_valid
        end
      end

      it 'Can not set nil' do
        tv.anime = nil
        expect(tv).not_to be_valid
      end

      it 'Can set nil when column has option of allow_nil true.' do
        tv.favorite = nil
        expect(tv).to be_valid
      end
    end
  end
end
