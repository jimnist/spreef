# this stuff is for refinerycms, camelize, schmamelize
# comes from http://refinerycms.com/guides/with-an-existing-rails-31-devise-app
module Spree
  Role.class_eval do

    # before_validation :camelize_title
    validates :name, :uniqueness => true

    # def camelize_title(role_title = self.title)
    #   self.title = role_title.to_s.camelize
    # end

    # def self.[](title)
    #   find_or_create_by_title(title.to_s.camelize)
    # end
    def self.[](name)
      find_or_create_by_name(name.to_s)
    end
  end
end