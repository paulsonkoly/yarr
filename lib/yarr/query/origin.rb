module Yarr
  module Query
    # Origin model.
    #
    # A name of a gem or core.
    class Origin < Sequel::Model
      # @!attribute [r] name
      #   @return [String] the originating gem name. 'core' for cores.
    end
  end
end
