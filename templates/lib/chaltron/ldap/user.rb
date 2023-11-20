# LDAP extension for Chaltron::User
#
# * Find or create user from omniauth.auth data
#

require "chaltron/ldap/person"

module Chaltron
  module Ldap
    class User
      class << self
        attr_reader :auth

        def find_or_create(auth, create)
          @auth = auth
          if uid.blank? || email.blank? || username.blank?
            raise_error("Account must provide a dn, uid and email address")
          end
          user = find_by_uid_and_provider
          entry = Chaltron::Ldap::Person.find_user(username)
          if user.nil? && create
            # create user with default roles
            user = entry.create_user(Chaltron::Role.where(name: Chaltron.default_roles))
          end
          # update email, department and roles from ldap
          update_ldap_attributes(user, entry) unless user.nil?
          user
        end

        private

        def update_ldap_attributes(user, entry)
          user.email = entry.email
          user.department = entry.department
          if Chaltron.ldap_role_mappings.present?
            user.roles = entry.ldap_groups.filter_map do |e|
              Chaltron::Role.find_by(name: Chaltron.ldap_role_mappings[e.dn])
            end
          end
          user.save
        end

        def find_by_uid_and_provider
          # LDAP distinguished name is case-insensitive
          user = Chaltron::OmniUser.where("provider = ? and lower(extern_uid) = ?", provider, uid.downcase).last
          if user.nil?
            # Look for user with same emails
            #
            # Possible cases:
            # * When user already has account and need to link their LDAP account.
            # * LDAP uid changed for user with same email and we need to update their uid
            #
            user = Chaltron::OmniUser.find_by(email: email)
            user&.update!(extern_uid: uid, provider: provider)
          end
          user
        end

        def uid
          auth.info.uid || auth.uid
        end

        def email
          auth&.info&.email&.downcase
        end

        def name
          auth.info.name.to_s.force_encoding("utf-8")
        end

        def username
          auth.info.nickname.to_s.force_encoding("utf-8")
        end

        def provider
          "ldap"
        end

        def raise_error(message)
          raise OmniAuth::Error, "(LDAP) #{message}"
        end
      end
    end
  end
end
