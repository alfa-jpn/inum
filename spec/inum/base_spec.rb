require 'spec_helper'

describe Inum::Base do
  describe '.define' do
    context 'When define a correct enum' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 0
          define :MONSTER,  1
          define :MONSTER2, 2
        }
      end

      it 'pass validation.' do
        expect { subject }.not_to raise_error
      end
    end

    context 'When define a omit a value enum' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL
          define :MONSTER
          define :MONSTER2
        }
      end

      it 'pass validation.' do
        expect { subject }.not_to raise_error
      end

      it 'auto incremented value.' do
        expect(subject::RED_BULL.to_i).to eq(0)
        expect(subject::MONSTER.to_i).to  eq(1)
        expect(subject::MONSTER2.to_i).to eq(2)
      end
    end

    context 'When define a enum with wrong label' do
      subject do
        Class.new(Inum::Base) {
          define 'red_bull', 0
        }
      end

      it 'Raise ArgumentError.' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When define a enum with duplicated label' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 0
          define :RED_BULL, 1
        }
      end

      it 'Raise ArgumentError.' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When define a enum with nan value' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 'hahaha'
        }
      end

      it 'Raise ArgumentError.' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When define a enum with duplicate value' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 0
          define :MONSTER,  0
        }
      end

      it 'Raise ArgumentError.' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Defined enum class' do
    before :each do
      class Anime < Inum::Base
        define :Nyaruko,   0
        define :Muromisan, 1
        define :Nourin,    2
        define :KMB,       3
        define :BakuOn,    5
      end
    end

    after :each do
      Object.class_eval{ remove_const :Anime }
    end

    describe '#<=>' do
      context 'self == other' do
        it 'Return 0.' do
          expect(Anime::Muromisan <=> 1).to eq(0)
        end
      end

      context 'self < other' do
        it 'Return a negative values.' do
          expect(Anime::Muromisan <=> 2).to be < 0
        end
      end

      context 'self > other' do
        it 'Return a positive values.' do
          expect(Anime::Muromisan <=> 0).to be > 0
        end
      end
    end

    describe '#+' do
      it 'Returning value is correct.' do
        expect(Anime::Nyaruko + 1).to eq(Anime::Muromisan)
      end
    end

    describe '#-' do
      it 'Returning value is correct.' do
        expect(Anime::Muromisan - 1).to eq(Anime::Nyaruko)
      end
    end

    describe '#eql?' do
      context 'When compare same enum' do
        it 'Return truthy value.' do
          expect(Anime::KMB.eql?(Anime::KMB)).to be_truthy
        end
      end

      context 'When compare other enum' do
        it 'Return falsey value.' do
          expect(Anime::KMB.eql?(Anime::Nyaruko)).to be_falsey
        end
      end
    end

    describe '#t' do
      subject do
        expect(I18n).to receive(:t).with(key).once { 'ok' }
        expect(Anime::KMB.t).to eq('ok')
      end

      let(:key) { 'anime.kmb' }

      it 'behaviour is right.' do
        subject
      end

      context 'override .i18n_key' do
        before :each do
          Anime.define_singleton_method(:i18n_key) {|path, label| "inum.#{path}.#{label}" }
        end

        let(:key) { 'inum.anime.kmb' }

        it 'Use overridden key.' do
          subject
        end
      end
    end

    describe '#to_i' do
      it 'Return integer.' do
        expect(Anime::KMB.to_i).to eq(3)
      end
    end

    describe '#to_s ' do
      it 'Return string.' do
        expect(Anime::Nourin.to_s).to eq('Nourin')
      end
    end

    describe '#dowcase ' do
      it 'Return lowercase string.' do
        expect(Anime::BakuOn.downcase).to eq('bakuon')
      end
    end

    describe '#upcase ' do
      it 'Return uppercase string.' do
        expect(Anime::BakuOn.upcase).to eq('BAKUON')
      end
    end

    describe '#underscore ' do
      it 'Return underscore string.' do
        expect(Anime::BakuOn.underscore).to eq('baku_on')
      end
    end

    describe '#translate' do
      subject do
        expect(I18n).to receive(:t).with('anime.kmb') { 'ok' }
        expect(Anime::KMB.translate).to eq('ok')
      end

      it 'behaviour is right.' do
        subject
      end
    end

    describe '#value' do
      it 'Return integer.' do
        expect(Anime::KMB.value).to eq(3)
      end
    end

    describe '.new' do
      it 'Can not create a instance of enum.' do
        expect{ Anime.new(:NICONICO, 2525) }.to raise_error(NoMethodError)
      end
    end

    describe '.each' do
      it 'Execute block with a right order.' do
        count  = 0
        orders = [Anime::Nyaruko, Anime::Muromisan, Anime::Nourin, Anime::KMB, Anime::BakuOn]

        Anime.each do |enum|
          expect(enum).to eq(orders[count])
          count += 1
        end
      end
    end

    describe '.form_items' do
      subject do
        allow(I18n).to receive(:t) { |key| "t-key-#{key}" }
        Anime.form_items(option)
      end

      let(:option) { Hash.new }

      it 'Return all item array.' do
        expect(subject).to match_array([
          ['t-key-anime.nyaruko',   'Nyaruko'],
          ['t-key-anime.muromisan', 'Muromisan'],
          ['t-key-anime.nourin',    'Nourin'],
          ['t-key-anime.kmb',       'KMB'],
          ['t-key-anime.baku_on',   'BakuOn'],
        ])
      end

      context 'When with only option' do
        let(:option) { {only: [:KMB]} }

        it 'Return only selected item array.' do
          expect(subject).to match_array([['t-key-anime.kmb', 'KMB']])
        end
      end

      context 'When with except option' do
        let(:option) { {except: [:KMB]} }

        it 'Return only except item array.' do
          expect(subject).to match_array([
            ['t-key-anime.nyaruko',   'Nyaruko'],
            ['t-key-anime.muromisan', 'Muromisan'],
            ['t-key-anime.nourin',    'Nourin'],
            ['t-key-anime.baku_on',   'BakuOn'],
          ])
        end
      end
    end

    describe '.labels' do
      it 'Return array of label.' do
        expect(Anime.labels).to match_array([:Nyaruko, :Muromisan, :Nourin, :KMB, :BakuOn])
      end
    end

    describe '.length' do
      it 'Return correct count of enum.' do
        expect(Anime.length).to eq(5)
      end
    end

    describe '.parse' do
      subject do
        expect(Anime.parse(source)).to eq(destination)
      end

      let(:destination) { Anime::BakuOn }

      context 'When source is string' do
        let(:source) { 'baku_on' }
        it 'Return inum.' do
          subject
        end
      end

      context 'When source is symbol' do
        let(:source) { :baku_on }
        it 'Return inum.' do
          subject
        end
      end

      context 'When source is integer' do
        let(:source) { 5 }
        it 'success.' do
          subject
        end
      end

      context 'When source is integer of string' do
        let(:source) { '5' }
        it 'Return inum.' do
          subject
        end
      end

      context 'When source is enum' do
        let(:source) { Anime::BakuOn }
        it 'Return inum.' do
          subject
        end
      end

      context 'When source is incorrect' do
        let(:source) { '' }
        let(:destination) { nil }
        it 'Return inum.' do
          subject
        end
      end
    end

    describe '.parse!' do
      subject do
        expect(Anime).to receive(:parse).with(:hoge) { returning_value }
        expect(Anime.parse!(:hoge)).to eq(returning_value)
      end

      context 'When #parse return enum' do
        let(:returning_value) { Anime::KMB }

        it 'Return inum.' do
          subject
        end
      end

      context 'When #parse return nil' do
        let(:returning_value) { nil }

        it 'Raise Inum::NotDefined.' do
          expect{subject}.to raise_error(Inum::NotDefined)
        end
      end
    end

    describe '.to_a' do
      it 'Return array of enum.' do
        expect(Anime.to_a).to match_array([Anime::Nyaruko, Anime::Muromisan, Anime::Nourin, Anime::KMB, Anime::BakuOn])
      end
    end

    describe '.values' do
      it 'Return array of value.' do
        expect(Anime.values).to match_array([0, 1, 2, 3, 5])
      end
    end

    context 'After extend Anime' do
      describe 'Defined enum class' do
        before :each do
          class Anime2016 < Anime
            define :GanbaruZoi, 4
          end
        end

        after :each do
          Object.class_eval{ remove_const :Anime2016 }
        end

        describe '.values' do
          it 'Return array of value.' do
            expect(Anime2016.values).to match_array([0, 1, 2, 3, 4, 5])
          end

          it 'Order is valid.' do
            expect(Anime2016.values[4]).to eq(4)
          end
        end

        describe 'extend enum' do
          it 'is no impact.' do
            expect(Anime.length).to eq(5)
          end
        end
      end
    end
  end
end
