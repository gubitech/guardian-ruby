class AuthenticationController < ApplicationController

  skip_before_action :login_required, :only => [:login]

  def login
    if request.post?
      if user = User.authenticate(params[:username], params[:password])
        self.current_user = user
        redirect_to root_path
      else
        flash.now[:alert] = "The username and/or password entered was invalid. Please check and try again."
      end
    end
  end

  def logout
    auth_session.invalidate! if logged_in?
    reset_session
    redirect_to login_path, :notice => "You have been logged out successfully"
  end

end
