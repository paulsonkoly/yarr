module Yarr
  module Query
    # Extends the from database url fragment to be a full url.
    module URLCorrector
      # @return [String] the ri url
      def url
        if core?
          "core-2.5.3/#{super}"
        else
          "stdlib-2.5.3/libdoc/#{origin.name}/rdoc/#{super}"
        end
      end

      # @return [Bool] is our origin 'core'
      def core?
        origin.name == 'core'
      end
    end
  end
end
