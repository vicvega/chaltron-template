module Chaltron
  class UsersController < ApplicationController
    include Searching
    include Sorting
    include Paginating

    with_options only: :index do
      preserve :page, :per_page, :sort_direction, :sort_column
      preserve :filter, :search, allow_blank: true
    end

    before_action :authenticate_user!
    before_action :set_filter
    load_and_authorize_resource

    logging category: :user_admin

    def index
      paginates defaults: {per_page: 10}
      sorts "created_at", "username", "email", "sign_in_count"
      @users = @users.filter_by(@filter).search_by(search)
      count_for_filters
      @users = @users.includes(:roles, avatar_attachment: :blob)
        .order("#{sort_column} #{sort_direction}")
      @pagy, @users = pagy(@users, items: per_page, page:)
    end

    def enable
      @user.enable!
      redirect_to(chaltron_users_path, notice: t("chaltron.users.enabled"))
    end

    def disable
      if current_user == @user
        options = {alert: t("chaltron.users.cannot_self_disable")}
      else
        @user.disable!
        options = {notice: t("chaltron.users.disabled")}
      end
      redirect_to(chaltron_users_path, **options)
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
        options = {alert: t("chaltron.users.cannot_self_destroy")}
      else
        @user.destroy!
        info t("chaltron.logs.users.destroyed", current: current_user.display_name, user: @user.display_name)
        options = {notice: t("chaltron.users.deleted")}
      end
      redirect_to(chaltron_users_path, **options)
    end

    private

    def count_for_filters
      users = Chaltron::User.accessible_by(current_ability).filter_by(@filter).search_by(search)
      db_count = users.group(:provider).count
        .transform_keys { |k| k.nil? ? "local" : k }
      @providers = I18n.t("chaltron.users.provider").each_with_object({}) do |(k, v), a|
        a[k.to_s] = "#{v} (#{db_count[k.to_s] ||= 0})"
      end.invert
      @never_logged_in = "#{Chaltron::Filters::User.human_attribute_name(:never_logged_in)} " \
                         "(#{users.where(sign_in_count: 0).count})"
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
