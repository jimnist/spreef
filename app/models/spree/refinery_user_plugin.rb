module Spree
  class RefineryUserPlugin < ActiveRecord::Base
    belongs_to :user
    attr_accessible :name, :position, :user_id
  end
end
