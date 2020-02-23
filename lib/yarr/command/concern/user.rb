require 'yarr/configuration'

module Yarr
  module Command
    module Concern
      # User related helper methods
      module User
        # Is the user an operator
        # @param user [Cinch::User|NoIRC::User] user
        def op?(user)
          user.host.match?(/\A#{Yarr.config.ops_host_mask}#{user.nick}\z/)
        end

        module_function :op?
      end
    end
  end
end
