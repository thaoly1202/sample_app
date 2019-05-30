class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new show create)
  before_action :load_user, except: %i(new index create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def new
    @user = User.new
  end

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.per_page
  end

  def show; end

  def edit; end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash.now[:success] = t "label.welcome"
      redirect_to @user
    else
      render :new
    end
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "label.update_profile"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "label.del_user"
      redirect_to users_path
    else
      flash[:danger] = t "errors.nil_user"
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email,
      :password, :password_cormfirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "label.pls_login"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "errors.nil_user"
    redirect_to root_path
  end
end
