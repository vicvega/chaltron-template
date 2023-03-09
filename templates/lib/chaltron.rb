require "syslog"
module Chaltron
  mattr_accessor :default_roles
  @@default_roles = []

  mattr_accessor :ldap_allow_all
  @@ldap_allow_all = false

  mattr_accessor :ldap_field_mappings
  @@ldap_field_mappings = {
    full_name: "cn",
    last_name: "sn",
    department: "department",
    email: "mail"
  }

  mattr_accessor :ldap_group_base
  @@ldap_group_base = nil

  mattr_accessor :ldap_group_member_filter
  @@ldap_group_member_filter = ->(entry) { "uniquemember=#{entry.dn}" }

  mattr_accessor :ldap_role_mappings
  @@ldap_role_mappings = {}

  def self.setup
    yield self
  end

  def self.table_name_prefix
    "chaltron_"
  end
end
