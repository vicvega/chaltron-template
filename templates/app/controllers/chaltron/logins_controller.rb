module Chaltron
  class LoginsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    def destroy
      current_user.logins.find(params[:id]).destroy!
      redirect_to(chaltron_self_user_show_path, notice: t("chaltron.logins.deleted"))
    end
  end
end
