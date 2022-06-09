module Chaltron
  class UsersController < ApplicationController
    include SearchSortAndPaginate
    helper_method :filter_provider, :filter_activity
    before_action :authenticate_user!
    load_and_authorize_resource

    respond_to :html
    default_log_category :user_admin

    # default_sort_column :created_at
    # default_sort_direction :desc
    default_per_page 10
    permitted_sort_columns %w[created_at username email sign_in_count]

    def index
      @users = @users.search(filter_search)

      @users = @users.where(provider: nil) if filter_provider == 'local'
      @users = @users.where(provider: :ldap) if filter_provider == 'ldap'
      @users = @users.where(sign_in_count: 0) if filter_activity == 'no_login'

      @count_users_ldap = @users.where(provider: :ldap).count
      @count_users_local = @users.where(provider: nil).count
      @count_users_inactive = @users.where(sign_in_count: 0).count

      @pagy, @users = pagy @users.order("#{sort_column} #{sort_direction}"), items: per_page
    end

    def enable
      @user.enable!
      redirect_to(@user, notice: I18n.t('chaltron.users.enabled'))
    end

    def disable
      @user.disable!
      redirect_to(@user, notice: I18n.t('chaltron.users.disabled'))
    end

    def show(user)
      @user = user
    end

    def edit(user)
      @user = user
    end

    def update(user)
      flash[:notice] = I18n.t('chaltron.users.updated') if user.update(update_params)
      redirect_to user
    end

    def destroy(user)
      options = { status: :see_other }
      if current_user == user
        options[:alert] = I18n.t('chaltron.users.cannot_self_destroy')
      else
        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: user.display_name)
        options[:notice] = I18n.t('chaltron.users.deleted')
        user.destroy
      end
      redirect_to({ controller: :users, action: :index }, options)
    end

    private

    def filter_activity
      %w[no_login].include?(params[:activity]) ? params[:activity] : nil
    end

    def filter_provider
      %w[local ldap].include?(params[:provider]) ? params[:provider] : nil
    end
  end
end
