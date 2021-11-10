module Chaltron
  class UsersController < ApplicationController
    include SortAndPaginate
    helper_method :filter_provider, :filter_activity
    before_action :authenticate_user!
    load_and_authorize_resource except: %i[self_show self_edit self_update change_password]

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

    def change_password
      redirect_to root_path unless current_user.provider.nil?
    end

    def create
      if @user.save
        flash[:notice] = I18n.t('chaltron.users.created')
        info I18n.t('chaltron.logs.users.created', current: current_user.display_name, user: @user.display_name)
      end
      respond_with(@user)
    end

    def update
      flash[:notice] = I18n.t('chaltron.users.updated') if @user.update(update_params)
      respond_with(@user)
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
      change_pwd = self_update_params.include?(:password)
      if current_user.update(self_update_params)
        # to mantain session after password change
        bypass_sign_in(current_user) if change_pwd
        flash[:notice] = I18n.t('chaltron.users.self_updated')
        redirect_to action: :self_show
      else
        back = :self_edit
        back = :change_password if change_pwd
        render back, status: :unprocessable_entity
      end
    end

    def destroy
      if current_user == @user
        redirect_to({ action: :index }, alert: I18n.t('chaltron.users.cannot_self_destroy'))
      else
        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: @user.display_name)
        @user.destroy
        respond_with(@user)
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
      allowed = %i[fullname password password_confirmation]
      allowed << :email if current_user.provider.nil?
      params.require(:chaltron_user).permit(allowed)
    end

    def filter_params
      params.fetch(:filters, {}).permit(:provider, :activity)
    end
  end
end
