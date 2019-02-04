module Yarr
  # Null object for no IRC connection
  class NoIRC
    # Returns a user list on which find always returns nil
    # @return [#find] empty user list
    def user_list
      Object.new.tap do |obj|
        obj.singleton_class.define_method(:find) { |*args| }
      end
    end
  end
end
