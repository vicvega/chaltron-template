require "chaltron/ldap/connection"

module Chaltron
  module Ldap
    class Person
      class << self
        extend Forwardable
        def_delegators :ldap, :find_users, :find_user
      end
      extend Forwardable
      attr_accessor :entry
      def_delegators :entry, :dn

      def self.valid_credentials?(login, password)
        ldap.auth(login, password)
      end

      def initialize(entry, uid)
        # Rails.logger.debug { "Instantiating #{self.class.name} with LDIF:\n#{entry.to_ldif}" }
        @entry = entry
        @uid = uid
      end

      def create_user(roles = [])
        user = Chaltron::LdapUser.new(
          extern_uid: dn,
          provider: provider,
          fullname: name,
          username: username,
          email: email,
          department: department
        )
        user.roles = roles
        user.save
        user
      end

      def department
        entry.send(Chaltron.ldap_field_mappings[:department]).first
      rescue
        nil
      end

      def name
        if Chaltron.ldap_field_mappings[:full_name].nil?
          first_name = entry.send(Chaltron.ldap_field_mappings[:first_name]).first
          last_name = entry.send(Chaltron.ldap_field_mappings[:last_name]).first
          "#{first_name} #{last_name}"
        else
          entry.send(Chaltron.ldap_field_mappings[:full_name]).first
        end
      end

      def uid
        entry.send(@uid).first
      end

      def username
        uid
      end

      def email
        entry.send(Chaltron.ldap_field_mappings[:email]).first
      rescue
        nil
      end

      def provider
        "ldap"
      end

      def ldap_groups
        self.class.ldap.find_groups_by_member(self)
      end

      def self.ldap
        @ldap ||= Chaltron::Ldap::Connection.new
      end
    end
  end
end
