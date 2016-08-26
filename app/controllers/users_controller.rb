class UsersController < ApplicationController

  before_action { params[:id] && @user = User.find(params[:id]) }

  def index
    @users = User.order(:username)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:username, :password))
    if @user.save
      redirect_to users_path, :notice => "#{@user.username} has been created successfully"
    else
      render 'new'
    end
  end

  def update
    if @user.update(params.require(:user).permit(:username, :password))
      redirect_to users_path, :notice => "#{@user.username} has been updated successfully"
    else
      render 'edit'
    end
  end

  def destroy
    if @user == current_user
      redirect_to edit_user_path(@user), :alert => "You cannot remove yourself"
      return
    end
    @user.destroy
    redirect_to users_path, :notice => "#{@user.username} has been removed successfully"
  end

end
