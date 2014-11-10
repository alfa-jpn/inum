require 'rspec'
require 'spec_helper'

describe Inum::ActiveRecordMixin do
  create_temp_table(:tvs){|t| t.integer :anime}

  before :each do
    class Anime < Inum::Base
      define :NYARUKO,   0
      define :MUROMISAN, 1
      define :NOURIN,    2
      define :KMB,       4
    end

    class TV < ActiveRecord::Base; end
  end

  after :each do
    Object.class_eval do
      remove_const :TV
      remove_const :Anime
    end
  end

  let :bind_class do
    TV.tap {|klass| klass.instance_eval{ bind_inum :anime, Anime } }
  end

  let :instance do
    bind_class.create!(anime: type)
  end

  let :type do
    Anime::NYARUKO
  end

  describe 'Comparison methods' do
    it 'Will be defined.' do
      expect(bind_class.method_defined?(:anime_nyaruko?)).to   be_truthy
      expect(bind_class.method_defined?(:anime_muromisan?)).to be_truthy
      expect(bind_class.method_defined?(:anime_nourin?)).to    be_truthy
      expect(bind_class.method_defined?(:anime_kmb?)).to       be_truthy
    end

    it 'Return correct value.' do
      expect(instance.anime_nyaruko?).to be_truthy
    end
  end

  describe '#setter' do
    subject do
      expect {
        instance.anime = target
      }.to change {
        instance.send(:read_attribute, :anime)
      }.from(type.to_i).to(Anime.parse(target).to_i)
    end

    context 'When enum' do
      let(:target){ Anime::NOURIN }

      it 'set value.' do
        subject
      end
    end

    context 'When integer' do
      let(:target){ 1 }

      it 'set value.' do
        subject
      end
    end

    context 'When string' do
      let(:target){ 'KMB' }

      it 'set value.' do
        subject
      end
    end

    context 'When string' do
      let(:target){ :KMB }

      it 'set value.' do
        subject
      end
    end

    context 'When integer value of string' do
      let(:target){ '1' }

      it 'set value.' do
        expect {
          instance.anime = target
        }.to change {
          instance.send(:read_attribute, :anime)
        }.from(type.to_i).to(Anime.parse(1).to_i)
      end
    end
  end

  describe '#getter' do
    it 'Return enum' do
      expect(instance.anime.instance_of?(Anime)).to be_truthy
    end
  end

  context 'When with prefix option' do
    let :bind_class do
      TV.tap {|klass| klass.instance_eval{ bind_inum :anime, Anime, prefix: 'prefix' } }
    end

    describe 'Comparison methods' do
      it 'Will be defined with prefix.' do
        expect(bind_class.method_defined?(:prefix_nyaruko?)).to   be_truthy
      end
    end
  end
end
