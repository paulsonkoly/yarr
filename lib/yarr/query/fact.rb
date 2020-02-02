module Yarr
  module Query
    # Facts model.
    #
    # Factoid is a short sentence that can be triggered by a keyword ({name}).
    # The bot will usuall respond with the content of the factoid.
    class Fact < Sequel::Model
      # @!attribute [r] name
      #   @return [String] the name (trigger word) for the factoid.
      # @!attribute [r] count
      #   @return [Integer] The number of times this factoid has been called.
      # @!attribute [r] content
      #   @return [String] The factoid content.
    end
  end
end
