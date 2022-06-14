module Chaltron
  class LocalUsersController < UsersController
    default_log_category :user_admin

    def new; end

    def create
      if @local_user.save
        flash[:notice] = I18n.t('chaltron.local_users.created')
        info I18n.t('chaltron.logs.users.created', current: current_user.display_name, user: @local_user.display_name)
        redirect_to chaltron_users_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def create_params
      params.require(:chaltron_local_user).permit(:username, :email, :fullname, :password, :password_confirmation,
                                                  role_ids: [])
    end
  end
end
