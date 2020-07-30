# frozen_string_literal: true

require 'yarr/error'

module Yarr
  module Command
    module Concern
      # Writes a response instance method for your class.
      #
      # +target+ has to be implemented in the including class and has to return
      # a textual description of the object that will be included in response
      # messages.
      module Responder
        # String appeneded to the output if we want to give advice to the user
        def advice
          ''
        end

        private

        def zero_response
          message = "Found no entry that matches #{target}"
          raise AnswerAmbiguityError, message
        end

        def multi_response(count)
          message = +"I found #{count} entries matching #{target}."
          message << ' ' << advice unless advice.empty?
          raise AnswerAmbiguityError, -message
        end

        # @!parse
        #  # @!macro [attach] define_single_item_responder
        #  #   @!method response(dataset)
        #  #   Responds with a string for the dataset.
        #  #   When the dataset is empty or has many items our response would
        #  #   report back that to the user, otherwise the client code defines
        #  #   what the response should be.
        #  #   This method was defined by
        #  #   {KlassMethods#define_single_item_responder
        #  #   define_single_item_responder}
        #  #   @param dataset [Array] the dataset we respond to
        #  #   @return [String] message to the user
        #  def self.define_single_item_responder(*) end
        #  private_class_method :define_single_item_responder
        #  # @!macro [attach] define_multi_item_responder
        #  #   @!method response(dataset)
        #  #   Responds with a string for the dataset.
        #  #   When the dataset is empty our response would report back that to
        #  #   the user, otherwise the client code defines what the response
        #  #   should be.
        #  #   This method was defined
        #  #   by {KlassMethods#define_multi_item_responder
        #  #   define_multi_item_responder}
        #  #   @param dataset [Array] the dataset we respond to
        #  #   @return [String] message to the user
        #  def self.define_multi_item_responder(*) end
        #  private_class_method :define_multi_item_responder

        # DSL to define response method
        module KlassMethods
          # Defines a single item dataset responder
          #
          # When the dataset is empty or has many items our response would
          # report back that to the user, otherwise the client code defines
          # what the response should be.
          # @param block [Proc] user hook to transform the dataset to response
          #   string
          # @yieldparam dataset [Array] query result
          def define_single_item_responder(&block)
            define_method(:response) do |dataset|
              count = dataset.count
              case count
              when 0 then zero_response
              when 1 then block[dataset]
              else multi_response(count)
              end
            end
          end

          # Defines multi item dataset responder
          #
          # When the dataset is empty our response would report back that to
          # the user, otherwise the client code defines what the response
          # should be.
          # @param block [Proc] user hook to transform the dataset to response
          #   string
          # @yieldparam dataset [Array] query result
          def define_multi_item_responder(&block)
            define_method(:response) do |dataset|
              case dataset.count
              when 0 then zero_response
              else block[dataset]
              end
            end
          end
        end

        def self.included(klass)
          klass.extend(KlassMethods)
        end

        private_class_method :included
      end
    end
  end
end
