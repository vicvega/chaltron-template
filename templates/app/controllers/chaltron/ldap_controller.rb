require 'chaltron/ldap/person'
module Chaltron
  class LdapController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_create_user

    default_log_category :user_admin

    def search
      @limit = default_limit
    end

    def multi_new
      @entries = []
      userid = params[:userid]
      if userid.present?
        entry = Chaltron::LDAP::Person.find_by_uid(userid)
        @entries << entry
      else
        @entries = Chaltron::LDAP::Person.find_by_fields(find_options)
      end
      @entries.compact!
      @entries.sort_by!(&:name)
    end

    def multi_create
      @created = []
      @error   = []
      (params[:uids] || []).each do |uid|
        roles = Chaltron::Role.find(params[:chaltron_user][:role_ids].compact_blank)
        user = Chaltron::LDAP::Person.find_by_uid(uid).create_user(roles)
        if user.new_record?
          @error << user
        else
          @created << user
        end
      end
      return unless @created.size.positive?

      info I18n.t('chaltron.logs.users.ldap_created',
                  current: current_user.display_name, count: @created.size,
                  user: @created.map(&:display_name).join(', '))
    end

    private

    def find_options
      department = params[:department]
      name       = params[:lastname]
      limit      = params[:limit].to_i

      ret = {}
      ret[:department] = "*#{department}*" if department.present?
      ret[:last_name]  = "*#{name}*"       if name.present?
      ret[:limit]      = limit.zero? ? default_limit : limit
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
