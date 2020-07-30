# frozen_string_literal: true

require_relative 'concern/user'

module Yarr
  module Command
    # Lists channel ops
    class Ops < Base
      include Concern::User

      # Can we handle the given AST?
      # @param ast [hash] parsed AST
      def self.match?(ast)
        ast[:command] == 'ops'
      end

      # Command handle
      def handle
        irc.user_list.select(&method(:op?)).map(&:nick).sort.join(', ')
      end
    end
  end
end
