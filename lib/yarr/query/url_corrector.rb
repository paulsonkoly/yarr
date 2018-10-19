module Yarr
  module Query
    module URLCorrector
      # @return [String] the ri url for the class
      def url
        if core?
          "core-2.5.1/#{super}"
        else
          "stdlib-2.5.1/libdoc/#{origin.name}/rdoc/#{super}"
        end
      end

      def core?
        origin.name == 'core'
      end
    end
  end
end
