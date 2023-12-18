module Chaltron
  class LocalUsersController < UsersController
    def new
    end

    def create
      if @local_user.save
        flash[:notice] = t("chaltron.local_users.created")
        info t("chaltron.logs.users.created", current: current_user.display_name, user: @local_user.display_name)
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
