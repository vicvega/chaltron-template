module Chaltron
  class UsersController < ApplicationController
    include SortAndPaginate
    helper_method :filter_provider, :filter_activity
    before_action :authenticate_user!
    load_and_authorize_resource except: %i[self_show self_edit self_update]

    respond_to :html
    default_log_category :user_admin

    # default_sort_column :created_at
    # default_sort_direction :desc
    default_per_page 10
    permitted_sort_columns %w[created_at username email]

    def index
      @users = @users.search(params[:search])

      @users = @users.where(provider: nil) if filter_provider == 'local'
      @users = @users.where(provider: :ldap) if filter_provider == 'ldap'
      @users = @users.where(sign_in_count: 0) if filter_activity == 'no_login'

      @count_users_ldap = @users.where(provider: :ldap).count
      @count_users_local = @users.where(provider: nil).count
      @count_users_inactive = @users.where(sign_in_count: 0).count

      @pagy, @users = pagy @users.order("#{sort_column} #{sort_direction}"), items: sort_per_page
    end

    def show; end

    def new; end

    def edit; end

    def self_show; end

    def self_edit; end

    def create
      if @user.save
        flash[:notice] = I18n.t('chaltron.users.created')
        info I18n.t('chaltron.logs.users.created', current: current_user.display_name, user: @user.display_name)
        redirect_to chaltron_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      flash[:notice] = I18n.t('chaltron.users.updated') if @user.update(update_params)
      redirect_to @user
    end

    def enable
      @user.enable!
      redirect_to(@user, notice: I18n.t('chaltron.users.enabled'))
    end

    def disable
      @user.disable!
      redirect_to(@user, notice: I18n.t('chaltron.users.disabled'))
    end

    def self_update
      user_params_with_pass = self_update_params.dup.to_h
      if params[:chaltron_user][:password].present?
        user_params_with_pass[:password] = params[:chaltron_user][:password]
        user_params_with_pass[:password_confirmation] = params[:chaltron_user][:password_confirmation]
      end
      if current_user.update(user_params_with_pass)
        flash[:notice] = I18n.t('chaltron.users.self_updated')
        render :self_show
      else
        render :self_edit
      end
    end

    def destroy
      if current_user == @user
        redirect_to({ action: :index }, alert: I18n.t('chaltron.users.cannot_self_destroy'))
      else
        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: @user.display_name)
        @user.destroy
        redirect_to chaltron_users_path
      end
    end

    private

    def filter_activity
      %w[no_login].include?(params[:activity]) ? params[:activity] : nil
    end

    def filter_provider
      %w[local ldap].include?(params[:provider]) ? params[:provider] : nil
    end

    def create_params
      params.require(:chaltron_user).permit(:username, :email, :fullname, :password, :password_confirmation,
                                            role_ids: [])
    end

    def update_params
      params.require(:chaltron_user).permit(role_ids: [])
    end

    def self_update_params
      allowed = [:fullname]
      allowed << :email if current_user.provider.nil?
      params.require(:chaltron_user).permit(allowed)
    end

    def filter_params
      params.fetch(:filters, {}).permit(:provider, :activity)
    end
  end
end
