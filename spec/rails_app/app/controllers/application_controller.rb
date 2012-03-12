class ApplicationController < ActionController::Base
  protect_from_forgery

  User = Struct.new('User', :id)

  def current_user
    User.new(5)
  end

  helper_method :current_user
end
