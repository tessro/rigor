class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :identify_subject

  User = Struct.new('User', :id)

  def identify_subject
    Rigor.identify_subject(User.new(5))
  end
end
