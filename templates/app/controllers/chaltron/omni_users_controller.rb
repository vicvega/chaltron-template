module Chaltron
  class OmniUsersController < UsersController
    def show
      super(@omni_user)
    end

    def edit
      super(@omni_user)
    end

    def update
      super(@omni_user)
    end

    def destroy
      super(@omni_user)
    end

    private

    def update_params
      params.require(:chaltron_omni_user).permit(role_ids: [])
    end
  end
end
