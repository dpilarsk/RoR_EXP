class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
    def index
	    if user_signed_in?
			redirect_to :controller => 'people', :action => :index
	    end
    end
  rescue_from CanCan::AccessDenied do |exception|
	  redirect_to(root_path, {:flash => { :error => "Access Denied" }})
  end
end
