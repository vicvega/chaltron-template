module Chaltron
  class UsersController < ApplicationController
    include Searching
    include Sorting
    include Paginating

    preserve :filter, :search, allow_blank: true

    before_action :authenticate_user!
    before_action :set_filter
    load_and_authorize_resource

    logging category: :user_admin
    with_options only: :index do
      sorting "created_at", "username", "email", "sign_in_count"
      paginating defaults: {per_page: 10}
    end

    def index
      @users = @users.filter_by(@filter).search_by(search)
      @count_filters = count_filters(@users)
      @users = @users.includes(:roles, avatar_attachment: :blob)
        .order("#{sort_column} #{sort_direction}")
      @pagy, @users = pagy(@users, items: per_page, page: page)
    end

    def enable
      @user.enable!
      message = t("chaltron.users.enabled")
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, notice: message) }
        format.turbo_stream do
          flash.now[:notice] = message
          render :update
        end
      end
    end

    def disable
      if current_user == @user
        message = t("chaltron.users.cannot_self_disable")
        flash.now[:alert] = message
        options = {alert: message}
      else
        @user.disable!
        message = t("chaltron.users.disabled")
        flash.now[:notice] = message
        options = {notice: message}
      end
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, **options) }
        format.turbo_stream { render :update }
      end
    end

    def edit
    end

    def update
      if @user.update(update_params)
        message = t("chaltron.users.updated")
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
      if current_user == @user
        message = t("chaltron.users.cannot_self_destroy")
        flash.now[:alert] = message
        options = {alert: message}
      else
        @user.destroy
        @count_filters = count_filters(Chaltron::User.accessible_by(current_ability).filter_by(@filter).search_by(search))
        info t("chaltron.logs.users.destroyed", current: current_user.display_name, user: @user.display_name)
        message = t("chaltron.users.deleted")
        flash.now[:notice] = message
        options = {notice: message}
      end
      respond_to do |format|
        format.html { redirect_to(chaltron_users_path, **options) }
        format.turbo_stream
      end
    end

    private

    def count_filters(users)
      {
        providers: users.group(:provider).count
          .transform_keys { |k| k.nil? ? "local" : k }
          .sort_by { |_k, v| v }.reverse.to_h,
        never_logged_in: users.where(sign_in_count: 0).count
      }
    end

    def set_filter
      @filter = Filters::User.new(filter_params)
    end

    def filter_params
      return {} if params[:filter].blank?

      params[:filter].permit(:search, :never_logged_in, providers: [])
    end

    def update_params
      params.require(:chaltron_user).permit(role_ids: [])
    end
  end
end
