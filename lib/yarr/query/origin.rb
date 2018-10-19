module Yarr
  module Query
    # Origin model.
    class Origin < Sequel::Model
      # @!attribute [r] name
      #   @return [String] the originating gem name. 'core' for cores.
    end
  end
end
