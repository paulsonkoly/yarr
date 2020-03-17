module Yarr
  module Command
    module Concern
      # Authorization capability for commands.
      #
      # Prepend this concern and call {authorize_for} at the class level.
      # The {User} concern can be included to have access to role predicate
      # methods like {User.op?}, then the role name becomes +op+.
      #
      # @example
      #
      #   class SomeCommand < Command
      #     include Concern::User
      #     prepend Concern::Authorize
      #
      #     authorize_for role: :op
      #
      #     def handle
      #       ..
      #     end
      #   end
      module Authorize
        # Prepended command handler
        def handle
          if send("#{role}?", user)
            super
          else
            "#{user.nick} is not authorized to execute command as #{role}"
          end
        end

        class << self
          private

          def prepended(klass)
            klass.extend(KlassMethods)
          end
        end

        # Class level DSL
        module KlassMethods
          # Defines what role is needed for the command to execute
          # @param role [Symbol] role name
          # @see Concern::User predicate methods to get list of roles
          def authorize_for(role:)
            @role = role
          end

          attr_reader :role
        end

        private

        def role
          self.class.role
        end
      end
    end
  end
end
