module Yarr
  module Message
    # Splits the incomming command into the following sections:
    #   - command (like 'list')
    #   - command target (like 'Array')
    #   - stuff (anything precedded by a ',')
    module Splitter
      ## performs splitting
      def split(message)
        command, _, rest = message.chomp.partition(/\s+/)
        target, _, stuff = rest.partition(',')

        [command, target, stuff]
      end
    end
  end
end
