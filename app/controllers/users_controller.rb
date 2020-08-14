class UsersController < ApplicationController
  before_action :get_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(new create)
  before_action :correct_user, only: %i(edit show update)
  before_action :admin_user, only: %i(index destroy)

  def index
    @users = User.page(params[:page]).per Settings.validations.users.per_page
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "users.new.notice_success"
      redirect_to @user
    else
      flash.now[:danger] = t "users.show.notice_error"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "inform_success"
      redirect_to @user
    else
      flash.now[:danger] = t "inform_success"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "inform_success"
    else
      flash[:danger] = t "inform_error"
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit User::USERS_PARAMS_PERMIT
  end

  def get_user
    @user = User.find_by id: params[:id] if params[:id]
    return if @user

    flash[:danger] = t "users.show.notice_error"
    redirect_to root_url
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "inform_login"
    redirect_to login_url
  end

  def correct_user
    redirect_to current_user unless current_user? @user
  end
end
