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
          "Found no entry that matches #{target}"
        end

        def multi_response(count)
          response = "I found #{count} entries matching #{target}."
          response << ' ' << advice unless advice.empty?
          response
        end

        # @!parse
        #  # @!macro [attach] define_responder
        #  #   @!method response(dataset)
        #  #   Responds with a string for the dataset. This method was defined
        #  #   by {KlassMethods#define_responder define_responder}
        #  #   @param dataset [Array] the dataset we respond to
        #  #   @return [String] message to the user
        #  def self.define_responder(*) end
        #  private_class_method :define_responder

        # DSL to define response method
        module KlassMethods
          # Defines the response instance method.
          # @param accept_many [Boolean] true for responders that can handle
          #   multiple results
          # @param block [Proc] user hook to transform the dataset to response
          #   string
          # @yieldparam dataset [Array] query result
          def define_responder(accept_many: true, &block)
            if accept_many
              define_binary_responder(block)
            else
              define_trinary_responder(block)
            end

            private :response
          end

          private

          def define_binary_responder(handler)
            define_method(:response) do |dataset|
              case dataset.count
              when 0 then zero_response
              else handler[dataset]
              end
            end
          end

          def define_trinary_responder(handler)
            define_method(:response) do |dataset|
              count = dataset.count
              case count
              when 0 then zero_response
              when 1 then handler[dataset]
              else multi_response(count)
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
