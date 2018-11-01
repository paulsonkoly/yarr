module Yarr
  module Query
    # Extends the from database url fragment to be a full url.
    module URLCorrector
      # @return [String] the ri url
      def url
        if core?
          "#{host}/core-2.5.3/#{super}"
        else
          "#{host}/stdlib-2.5.3/libdoc/#{origin.name}/rdoc/#{super}"
        end
      end

      # @return [Bool] is our origin 'core'
      def core?
        origin.name == 'core'
      end

      private

      def host
        'https://ruby-doc.org/'
      end
    end
  end
end
