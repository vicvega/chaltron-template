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
      @pagy, @users, @count_filters = search_filter_paginate(@users)
    end

    def enable
      @user.enable!
      message = I18n.t('chaltron.users.enabled')
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, notice: message) }
        format.turbo_stream do
          flash.now[:notice] = message
          render :update
        end
      end
    end

    def disable
      if current_user != @user
        @user.disable!
        message = I18n.t('chaltron.users.disabled')
        flash.now[:notice] = message
        options = { notice: message }
      else
        message = I18n.t('chaltron.users.cannot_self_disable')
        flash.now[:alert] = message
        options = { alert: message }
      end
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, **options) }
        format.turbo_stream { render :update }
      end
    end

    def edit; end

    def update
      if @user.update(update_params)
        message = I18n.t('chaltron.users.updated')
        respond_to do |format|
          format.html { redirect_to(chaltron_users_path, notice: message) }
          format.turbo_stream do
            flash.now[:notice] = message
            render :update
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if current_user != @user
        @user.destroy
        # re-order whole users list
        @pagy, @users, @count_filters = search_filter_paginate(Chaltron::User.accessible_by(current_ability))

        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: @user.display_name)
        message = I18n.t('chaltron.users.deleted')
        flash.now[:notice] = message
        options = { notice: message }
      else
        message = I18n.t('chaltron.users.cannot_self_destroy')
        flash.now[:alert] = message
        options = { alert: message }
      end
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, **options) }
        format.turbo_stream
      end
    end

    private

    def update_params
      params.require(:chaltron_user).permit(role_ids: [])
    end

    def filter_activity
      %w[no_login].include?(params[:activity]) ? params[:activity] : nil
    end

    def filter_provider
      %w[local ldap].include?(params[:provider]) ? params[:provider] : nil
    end

    def search_filter_paginate(users)
      users = users.includes(avatar_attachment: :blob).search(filter_search)

      users = users.where(provider: nil) if filter_provider == 'local'
      users = users.where(provider: :ldap) if filter_provider == 'ldap'
      users = users.where(sign_in_count: 0) if filter_activity == 'no_login'

      pagy, users = pagy(users.order("#{sort_column} #{sort_direction}"), items: per_page)
      count = {}
      count[:ldap] = users.where(provider: :ldap).count
      count[:local] = users.where(provider: nil).count
      count[:inactive] = users.where(sign_in_count: 0).count
      [pagy, users, count]
    end
  end
end
