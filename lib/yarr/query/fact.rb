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

      # Increments the count column by 1
      def increment_count
        update_fields({ count: Sequel[:count] + 1 }, [:count])
      end

      # does nothing as we don't support saving existing factoids
      def save_content(_)
        "I already know that #{name} is #{content}"
      end

      # Deletes this factoid
      def remove
        delete
        "I forgot what #{name} is."
      end

      # Null object for not finding a factoid
      class NoFact
        # @param name [String] factoid name
        def initialize(name)
          @name = name
        end

        # @see {Yarr::Query::Fact#increment_count}
        def increment_count; end

        # @see {Yarr::Query::Fact#content}
        def content
          "I don't know anything about #{@name}."
        end

        # Creates a new factoid with content
        def save_content(content)
          Fact.create(name: @name, content: content, count: 0)
          "I will remember that #{@name} is #{content}"
        end

        # Doesn't do anything, as factoid doesn't exist
        def remove
          "I never knew what #{@name} is."
        end
      end

      # Finds factoid by name
      # @return [Fact | Fact::NoFactoid] result object or null object
      def self.by_name(name)
        self[name: name] || NoFact.new(name)
      end
    end
  end
end
