require 'yarr/configuration'

module Yarr
  module Query
    # Extends the from database url fragment to be a full url.
    #
    # Mixin that assumes an instance method +#origin+ to exist and return an
    # {Yarr::Query::Origin}.
    module URLCorrector
      # @return [String] the ri url
      def url
        version = Yarr::CONFIG.ruby_version
        if core?
          "#{host}/core-#{version}/#{super}"
        else
          "#{host}/stdlib-#{version}/libdoc/#{origin.name}/rdoc/#{super}"
        end
      end

      # @return [Bool] is our origin 'core'
      def core?
        origin.name == 'core'
      end

      private

      def host
        'https://ruby-doc.org'
      end
    end
  end
end
