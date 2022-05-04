module Chaltron
  class LocalUsersController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    respond_to :html
    default_log_category :user_admin

    def show
      render 'chaltron/users/show', locals: { user: @local_user }
    end

    def new; end

    def edit
      render 'chaltron/users/edit', locals: { user: @local_user }
    end

    def create
      if @local_user.save
        flash[:notice] = I18n.t('chaltron.local_users.created')
        info I18n.t('chaltron.logs.users.created', current: current_user.display_name, user: @local_user.display_name)
        redirect_to chaltron_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      flash[:notice] = I18n.t('chaltron.users.updated') if @local_user.update(update_params)
      redirect_to @local_user
    end

    def destroy
      options = { status: :see_other }
      if current_user == @local_user
        options[:alert] = I18n.t('chaltron.users.cannot_self_destroy')
      else
        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: @local_user.display_name)
        options[:notice] = I18n.t('chaltron.users.deleted')
        @local_user.destroy
      end
      redirect_to({ controller: :users, action: :index }, options)
    end

    private

    def create_params
      params.require(:chaltron_local_user).permit(:username, :email, :fullname, :password, :password_confirmation,
                                                  role_ids: [])
    end

    def update_params
      params.require(:chaltron_local_user).permit(role_ids: [])
    end
  end
end
