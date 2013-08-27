Refinery::Admin::BaseController.class_eval do
  def require_refinery_users!
    false
  end
end