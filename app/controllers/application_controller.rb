class ApplicationController < ActionController::Base
  protect_from_forgery

  # include refinerycms and spree helpers so they
  # are available throughout the application
  helper Refinery::Core::Engine.helpers
  include Spree::Core::ControllerHelpers
  include Spree::BaseHelper
  helper 'spree/base'
  helper 'spree/products'
end
