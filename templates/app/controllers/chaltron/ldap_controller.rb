require "chaltron/ldap/person"
module Chaltron
  class LdapController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_create_user

    default_log_category :user_admin

    def search
      @limit = default_limit
    end

    def multi_new
      @entries = Chaltron::LDAP::Person.find_users(find_options)
      @entries.compact!
      @entries.sort_by!(&:name)
    end

    def multi_create
      @created = []
      @error = []
      (params[:uids] || []).each do |uid|
        roles = Chaltron::Role.find(params[:chaltron_user][:role_ids].compact_blank)
        user = Chaltron::LDAP::Person.find_user(uid).create_user(roles)
        if user.new_record?
          @error << user
        else
          @created << user
        end
      end
      return unless @created.size.positive?

      info t("chaltron.logs.users.ldap_created",
        current: current_user.display_name, count: @created.size,
        user: @created.map(&:display_name).join(", "))
    end

    private

    def find_options
      uid = params[:userid]
      department = params[:department]
      name = params[:lastname]
      limit = params[:limit].to_i

      ret = {}
      ret[Devise.omniauth_configs[:ldap].options[:uid].to_sym] = "*#{uid}*" if uid.present?
      ret[:department] = "*#{department}*" if department.present?
      ret[:last_name] = "*#{name}*" if name.present?
      ret[:limit] = limit.zero? ? default_limit : limit
      ret
    end

    def default_limit
      100
    end

    def authorize_create_user
      authorize! :create, User
    end
  end
end
