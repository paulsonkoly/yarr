require 'spec_helper'
require 'yarr/command/fake'

module Yarr
  module Command
    RSpec.describe Fake do
      context 'with Starwars.character' do
        let(:ast) do
          AST.new(command: 'fake',
                  class_method: { class_name: 'Movies::StarWars',
                                  method_name: 'character' })
        end
        let(:command) { described_class.new(ast: ast) }

        describe '#handle' do
          it 'gives some star wars characters' do
            expect(command.handle).not_to match 'error'
          end
        end
      end

      context 'with invalid faker' do
        let(:ast) do
          AST.new(command: 'fake',
                  class_method: { class_name: 'XXX',
                                  method_name: 'blah' })
        end
        let(:command) { described_class.new(ast: ast) }

        describe '#handle' do
          it 'complains' do
            expect(command.handle).to start_with 'No suitable faker found'
          end
        end
      end
    end
  end
end
