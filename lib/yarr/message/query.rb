require 'yarr/database'

module Yarr
  module Message
    # Message database access.
    module Query
      class << self
        # looks up an instance method or a class method with fully specified
        # names
        # @param method [String] the method name
        # @param klass [String] the class name
        # @param flavour [String] 'instance' | 'class'
        # @return [Sequel::Dataset] rows contain :url key
        def joined_query(method:, klass:, flavour:)
          DB[:classes]
            .join(:methods, class_id: :id)
            .where(Sequel[:methods][:name] => method,
          Sequel[:classes][:name] => klass,
          Sequel[:methods][:flavour] => flavour)
        end

        # looks up a class with fully specified name
        # @param klass [String] the class name
        # @return [Sequel::Dataset] rows contain :url key
        def klass_query(klass)
          DB[:classes].where(name: klass)
        end

        # looks up a method with fully specified name
        # @param method [String] the method name
        # @return [Sequel::Dataset] rows contain :url key
        def method_query(method)
          DB[:methods].where(name: method)
        end

        # looks up an instance method or a class method with % like wildcards
        # @param method [String] the method name
        # @param klass [String] the class name
        # @param flavour [String] 'instance' | 'class'
        # @return [Sequel::Dataset] rows contain keys :class_name, :method_name
        def joined_like_query(method:, klass:, flavour:)
          DB[:classes]
            .join(:methods, class_id: :id)
            .select(Sequel[:methods][:name].as(:method_name),
          Sequel[:classes][:name].as(:class_name))
            .where(Sequel[:methods][:name].like(method) &
          Sequel[:classes][:name].like(klass) &
          { Sequel[:methods][:flavour] => flavour })
        end

        # looks up a class with % like wildcards
        # @param klass [String] the class name
        # @return [Sequel::Dataset] rows contain :name key
        def klass_like_query(klass)
          Yarr::DB[:classes].where(Sequel[:name].like(klass))
        end

        # looks up a method with % like wildcards
        # @param method [String] the method name
        # @return [Sequel::Dataset] rows contain keys :class_name, :method_name
        #                           :method_flavour
        def method_like_query(method)
          Yarr::DB[:classes]
            .join(:methods, class_id: :id)
            .select(Sequel[:methods][:name].as(:method_name),
          Sequel[:classes][:name].as(:class_name),
          Sequel[:methods][:flavour].as(:method_flavour))
            .where(Sequel[:methods][:name].like(method))
        end
      end
    end
  end
end
