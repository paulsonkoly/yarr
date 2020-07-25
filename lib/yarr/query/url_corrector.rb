require 'yarr/configuration'

module Yarr
  module Query
    # Extends the from database url fragment to be a full url.
    #
    # Mixin that assumes an instance method +#origin+ to exist and return an
    # {Yarr::Query::Origin}.
    module URLCorrector
      HOST = 'https://ruby-doc.org'.freeze

      # @return [String] the ri url
      def url
        version = CONFIG.ruby_version
        if core?
          "#{HOST}/core-#{version}/#{super()}"
        else
          "#{HOST}/stdlib-#{version}/libdoc/#{origin.name}/rdoc/#{super()}"
        end
      end

      # @return [Bool] is our origin 'core'
      def core?
        origin.name.eql? 'core'
      end
    end
  end
end
