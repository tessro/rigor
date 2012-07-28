class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :identify_subject
  before_filter :load_experiments

  User = Struct.new('User', :id)

  def identify_subject
    Rigor.identify_subject(User.new(5))
  end

  # Load all experiments. This is normally done at Rails boot time, but in order
  # to enable auto-reloading of Rigor, we need to auto-reload all experiments.
  def load_experiments
    Rigor::Rails.load!
  end
end
