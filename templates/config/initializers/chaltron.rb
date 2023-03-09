require "chaltron"

Chaltron.setup do |config|
  # If LDAP enabled (see config/initializers/devise.rb), chaltron must use
  # email field and may use first_name, last_name, full_name, department.
  # Here is the field mapping on you own LDAP server.
  # Default values are the following:
  # config.ldap_field_mappings = {
  #   full_name: "cn",
  #   last_name: "sn",
  #   department: "department",
  #   email: "mail"
  # }

  # If LDAP enabled, set this to true to allow every ldap authenitcated
  # users to access you application
  # config.ldap_allow_all = false

  # You may set here default roles granted to new users (if automatically created)
  # config.default_roles = []

  # Here you may specify a different base for your LDAP groups
  # If not specified the :base parameter defined in Devise.omniauth_configs[:ldap] will be used
  # config.ldap_group_base = "ou=groups,dc=example,dc=com"

  # Here you may specify a filter to retrieve LDAP group membership
  # Accept entry (an instance of Chaltron::LDAP::Person) as parameter
  # Default is
  # config.ldap_group_member_filter = -> (entry) { "uniquemember=#{entry.dn}" }

  # Roles granted to new users may be retrieved by LDAP group membership.
  # config.ldap_role_mappings = {
  #   "DN_of_LDAP_group1" => "role1",
  #   "DN_of_LDAP_group2" => "role2"
  # }
end
