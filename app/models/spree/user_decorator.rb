# this stuff is for refinerycms
# comes from http://refinerycms.com/guides/with-an-existing-rails-31-devise-app
module Spree
  User.class_eval do

    # has_and_belongs_to_many :roles, :join_table => ::RolesUsers.table_name
    has_many :plugins, :class_name => "RefineryUserPlugin", :order => "position ASC", :dependent => :destroy

    def plugins=(plugin_names)
      if persisted? # don't add plugins when the user_id is nil.
        Spree::RefineryUserPlugin.delete_all(:user_id => id)

        plugin_names.each_with_index do |plugin_name, index|
          plugins.create(:name => plugin_name, :position => index) if plugin_name.is_a?(String)
        end
      end
    end

    def authorized_plugins
      plugins.collect(&:name) | ::Refinery::Plugins.always_allowed.names
    end

    def add_role(name)
      if name.is_a? Spree::Role
        raise ArgumentException, "Role should be the name of the role not a role object."
      end

      spree_roles << Role[name] unless has_role?(name)
    end

    def has_role?(name)
      if name.is_a? Spree::Role
        raise ArgumentException, "Role should be the name of the role not a role object."
      end

      spree_roles.any? { |r| r.name == name.to_s }
    end

    def can_delete?(user_to_delete = self)
      user_to_delete.persisted? &&
        !user_to_delete.has_role?(:superuser) &&
        Spree::Role[:refinery].users.any? &&
        id != user_to_delete.id
    end

    def can_edit?(user_to_edit = self)
      user_to_edit.persisted? && (user_to_edit == self || self.has_role?(:superuser))
    end

  end
end