module Chaltron
  class SelfUserController < ApplicationController
    before_action :authenticate_user!

    def show; end

    def edit; end

    def change_password
      redirect_to root_path unless current_user.provider.nil?
    end

    def update
      change_pwd = update_params.include?(:password)
      if current_user.update(update_params)
        # to mantain session after password change
        bypass_sign_in(current_user) if change_pwd
        flash[:notice] = I18n.t('chaltron.users.self_updated')
        redirect_to action: :show
      else
        back = :edit
        back = :change_password if change_pwd
        render back, status: :unprocessable_entity
      end
    end

    private

    def update_params
      allowed = %i[fullname password password_confirmation]
      allowed << :email if current_user.provider.nil?
      params.require(:chaltron_user).permit(allowed)
    end
  end
end
