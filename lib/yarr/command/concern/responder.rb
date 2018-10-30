module Yarr
  module Command
    module Concern
      # Writes a response instance method for your class.
      module Responder
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

        # DSL to define response method
        # @private
        module KlassMethods
          def respond_with(response:, options: {})
            accept_many = options.fetch(:accept_many, true)
            if accept_many
              define_binary_responder(response)
            else
              define_trinary_responder(response)
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
      end
    end
  end
end
