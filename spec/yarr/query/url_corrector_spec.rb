require 'spec_helper'
require 'yarr/query/url_corrector'


module Yarr
  module Query
    class Fake
      prepend URLCorrector

      def initialize(origin)
        @origin = origin
      end

      def origin
        @origin
      end

      def url
        'xxx'
      end
    end

    RSpec.describe URLCorrector do
      context 'when origin is "core"' do
        subject { Fake.new(double('core', name: 'core')) }

        describe '#core?' do
          it 'is true' do
            expect(subject.core?).to be true
          end
        end

        describe '#url' do
          it 'is the core url' do
            expect(subject.url).to match /core-\d.\d.\d\/xxx/
          end
        end
      end

      context 'when origin is "gem"' do
        subject { Fake.new(double('gem', name: 'gem')) }

        describe '#core?' do
          it 'is false' do
            expect(subject.core?).to be false
          end
        end

        describe '#url' do
          it 'is the stdlib url url' do
            expect(subject.url).to match %r{stdlib-\d.\d.\d/libdoc/gem/rdoc/xxx}
          end
        end
      end
    end
  end
end
