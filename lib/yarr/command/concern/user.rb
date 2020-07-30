# frozen_string_literal: true

require 'yarr/configuration'

module Yarr
  module Command
    module Concern
      # User related helper methods
      module User
        # Is the user an operator
        # @param user [Cinch::User|NoIRC::User] user
        def op?(user)
          nick = user.nick.delete('_')
          host = user.host_unsynced || ''

          nick.match?(/\A[\w]+\z/) &&
            host.match?(/\A#{Yarr::CONFIG.ops_host_mask}#{nick}\z/) &&
            user.online?
        end

        module_function :op?
      end
    end
  end
end
