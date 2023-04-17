module Chaltron
  class SelfUserController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def edit
    end

    def change_password
      redirect_to root_path unless current_user.is_a?(Chaltron::LocalUser)
    end

    def update
      if current_user.update(update_params)
        redirect_to chaltron_self_user_show_path, notice: t("chaltron.users.self_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def update_password
      password_present = password_params[:password].present?
      current_user.errors.add(:password, :blank) unless password_present
      if password_present && current_user.update_with_password(password_params)
        # to mantain session after password change
        bypass_sign_in(current_user)
        redirect_to chaltron_self_user_show_path, notice: t("chaltron.users.password_changed")
      else
        render :change_password, status: :unprocessable_entity
      end
    end

    private

    def update_params
      allowed = %i[fullname avatar]
      allowed.push(:email) if current_user.is_a?(Chaltron::LocalUser)
      params.require(:chaltron_user).permit(allowed)
    end

    def password_params
      params.require(:chaltron_user).permit(%i[current_password password password_confirmation])
    end
  end
end
