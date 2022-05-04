module Chaltron
  class OmniUsersController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    respond_to :html
    default_log_category :user_admin

    def show
      render 'chaltron/users/show', locals: { user: @omni_user }
    end

    def edit
      render 'chaltron/users/edit', locals: { user: @omni_user }
    end

    def update
      flash[:notice] = I18n.t('chaltron.users.updated') if @omni_user.update(update_params)
      redirect_to @omni_user
    end

    def destroy
      options = { status: :see_other }
      if current_user == @omni_user
        options[:alert] = I18n.t('chaltron.users.cannot_self_destroy')
      else
        info I18n.t('chaltron.logs.users.destroyed', current: current_user.display_name, user: @omni_user.display_name)
        options[:notice] = I18n.t('chaltron.users.deleted')
        @omni_user.destroy
      end
      redirect_to({ controller: :users, action: :index }, options)
    end

    private
    def update_params
      params.require(:chaltron_omni_user).permit(role_ids: [])
    end
  end
end
