require 'rspec'
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

    context 'When define a enum having wrong label' do
      subject do
        Class.new(Inum::Base) {
          define :red_bull, 0
        }
      end

      it 'fail validation.' do
        expect { subject }.to raise_error
      end
    end

    context 'When define a enum having duplicate label' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 0
          define :RED_BULL, 1
        }
      end

      it 'fail validation.' do
        expect { subject }.to raise_error
      end
    end

    context 'When define a enum having duplicate value' do
      subject do
        Class.new(Inum::Base) {
          define :RED_BULL, 0
          define :MONSTER,  0
        }
      end

      it 'fail validation.' do
        expect { subject }.to raise_error
      end
    end
  end

  describe 'Defined enum class' do
    before :all do
      class Anime < Inum::Base
        define :NYARUKO,   0
        define :MUROMISAN, 1
        define :NOURIN,    2
        define :KMB,       3
      end
    end

    after :all do
      Object.class_eval{ remove_const :Anime }
    end

    describe '#<=>' do
      context 'self == other' do
        it 'Return 0.' do
          expect(Anime::MUROMISAN <=> 1).to eq(0)
        end
      end

      context 'self < other' do
        it 'Return a negative values.' do
          expect(Anime::MUROMISAN <=> 2).to be < 0
        end
      end

      context 'self > other' do
        it 'Return a positive values.' do
          expect(Anime::MUROMISAN <=> 0).to be > 0
        end
      end
    end

    describe '#+' do
      it 'Returning value is correct.' do
        expect(Anime::NYARUKO + 1).to eq(Anime::MUROMISAN)
      end
    end

    describe '#-' do
      it 'Returning value is correct.' do
        expect(Anime::MUROMISAN - 1).to eq(Anime::NYARUKO)
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
          expect(Anime::KMB.eql?(Anime::NYARUKO)).to be_falsey
        end
      end
    end

    describe '#t' do
      subject do
        expect(I18n).to receive(:t).with('animes.kmb') { 'ok' }
        expect(Anime::KMB.t).to eq('ok')
      end
    end

    describe '#to_i' do
      it 'Return integer.' do
        expect(Anime::KMB.to_i).to eq(3)
      end
    end

    describe '#to_s ' do
      it 'Return string.' do
        expect(Anime::NOURIN.to_s).to eq('NOURIN')
      end
    end

    describe '#translate' do
      subject do
        expect(I18n).to receive(:t).with('animes.kmb') { 'ok' }
        expect(Anime::KMB.translate).to eq('ok')
      end
    end

    describe '#value' do
      it 'Return integer.' do
        expect(Anime::KMB.value).to eq(3)
      end
    end

    describe '.collection' do
      subject do
        allow(I18n).to receive(:t) { 't' }
        Anime.collection(option)
      end

      let(:option) { Hash.new }

      it 'Return all item array.' do
        expect(subject).to match_array([
          ['t', 0],
          ['t', 1],
          ['t', 2],
          ['t', 3],
        ])
      end

      context 'When with only option' do
        let(:option) { {only: [:KMB]} }

        it 'Return only selected item array.' do
          expect(subject).to match_array([['t', 3]])
        end
      end

      context 'When with except option' do
        let(:option) { {except: [:KMB]} }

        it 'Return only except item array.' do
          expect(subject).to match_array([
            ['t', 0],
            ['t', 1],
            ['t', 2],
          ])
        end
      end
    end

    describe '.new' do
      it 'Can not create a instance of enum.' do
        expect{ Anime.new(:NICONICO, 2525) }.to raise_error
      end
    end

    describe '.each' do
      it 'Execute block with a right order.' do
        count  = 0
        orders = [Anime::NYARUKO, Anime::MUROMISAN, Anime::NOURIN, Anime::KMB]

        Anime.each do |enum|
          expect(enum).to eq(orders[count])
          count += 1
        end
      end
    end

    describe '.labels' do
      it 'Return array of label.' do
        expect(Anime.labels).to match_array([:NYARUKO, :MUROMISAN, :NOURIN, :KMB])
      end
    end

    describe '.length' do
      it 'Return correct count of enum.' do
        expect(Anime.length).to eq(4)
      end
    end

    describe '.parse' do
      subject do
        expect(Anime.parse(source)).to eq(destination)
      end

      let(:destination) { Anime::KMB }

      context 'source is string' do
        let(:source) { 'KMB' }
        it 'success.' do
          subject
        end
      end

      context 'source is symbol' do
        let(:source) { :kmb }
        it 'success.' do
          subject
        end
      end

      context 'source is integer' do
        let(:source) { 3 }
        it 'success.' do
          subject
        end
      end

      context 'source is enum' do
        let(:source) { Anime::KMB }
        it 'success.' do
          subject
        end
      end

      context 'source is incorrect' do
        let(:source) { '' }
        let(:destination) { nil }
        it 'return nil.' do
          subject
        end
      end
    end

    describe '.parse!' do
      subject do
        expect(Anime).to receive(:parse).with(:hoge) { returning_value }
        expect(Anime.parse!(:hoge)).to eq(returning_value)
      end

      context '#parse return enum' do
        let(:returning_value) { Anime::KMB }

        it 'success.' do
          subject
        end
      end

      context '#parse return nil' do
        let(:returning_value) { nil }

        it 'raise error.' do
          expect{subject}.to raise_error
        end
      end
    end

    describe '.to_a' do
      it 'Return array of enum.' do
        expect(Anime.to_a).to match_array([Anime::NYARUKO, Anime::MUROMISAN, Anime::NOURIN, Anime::KMB])
      end
    end

    describe '.values' do
      it 'Return array of value.' do
        expect(Anime.values).to match_array([0, 1, 2, 3])
      end
    end
  end
end
