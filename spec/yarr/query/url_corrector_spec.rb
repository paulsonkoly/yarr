require 'spec_helper'
require 'yarr/query/url_corrector'
require 'yarr/query/origin'

module Yarr
  module Query
    class Fake
      prepend URLCorrector

      def initialize(origin)
        @origin = origin
      end

      attr_reader :origin

      def url
        'xxx'
      end
    end

    RSpec.describe URLCorrector do
      context 'when origin is "core"' do
        let(:corrector) { Fake.new(instance_double(Origin, name: 'core')) }

        describe '#core?' do
          it 'is true' do
            expect(corrector.core?).to be true
          end
        end

        describe '#url' do
          it 'is the core url' do
            expect(corrector.url).to match(%r{core-\d.\d(.\d)?/xxx})
          end
        end
      end

      context 'when origin is "gem"' do
        let(:corrector) { Fake.new(instance_double(Origin, name: 'gem')) }

        describe '#core?' do
          it 'is false' do
            expect(corrector.core?).to be false
          end
        end

        describe '#url' do
          it 'is the stdlib url url' do
            rexp = %r{stdlib-\d.\d(.\d)?/libdoc/gem/rdoc/xxx}
            expect(corrector.url).to match rexp
          end
        end
      end
    end
  end
end
