require 'yarr/command/base'
require 'yarr/query'
require 'yarr/command/concern/responder'

module Yarr
  module Command
    # Base class for all ri commands
    class Ri < Base
      include Concern::Responder

      def handle
        response(query)
      end

      respond_with(
        response: -> result { "https://ruby-doc.org/#{result.first.url}" },
        options: { accept_many: false })


      private

      def query
        raise NotImplementedError
      end

      def target
        raise NotImplementedError
      end
    end

    # Base class for ri commands handling calls.
    class RiCall < Ri
      private

      def query
        Query::Method.where(name: method,
                            flavour: flavour,
                            klass: Query::Klass.where(name: klass))
      end

      def target
        "class #{klass} #{flavour} method #{method}"
      end

      def flavour
        raise NotImplementedError
      end
    end

    # Handles 'ri Array#size' like commands
    class RiInstanceMethod < RiCall
      private def flavour
        'instance'
      end
    end

    # Handles 'ri Array.size' like commands
    class RiClassMethod < RiCall
      private def flavour
        'class'
      end
    end

    # Handles 'ri size' like commands
    class RiMethodName < Ri
      private

      def query
        Query::Method.where(name: method)
      end

      def target
        "method #{method}"
      end

      def advice
        "Use &list #{method} if you would like to see a list"
      end
    end

    # Handles 'ri File' like commands
    class RiClassName < Ri
      private

      def query
        constraints = { name: klass }
        constraints.merge!(origin: Query::Origin.where(name: origin)) if origin
        Query::Klass.where(constraints)
      end

      def target
        "class #{klass}"
      end

      # TODO
      # :reek:FeatureEnvy I cannot find a good way to fix this.

      def response(result)
        core = result.find(&:core?)
        if result.count > 1 && core
          "https://ruby-doc.org/#{core.url}"
        else
          super
        end
      end
    end
  end
end
