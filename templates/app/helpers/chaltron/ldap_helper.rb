module Chaltron
  module LdapHelper
    def display_entry_name(entry)
      capture do
        concat entry.name
        if User.exists?(username: entry.username)
          concat tag.span(t('chaltron.users.already_present'), class: 'badge bg-danger ms-1')
        end
      end
    end

    def display_entry_email(entry)
      entry.email.presence || tag.span(t('chaltron.users.missing_field'), class: 'badge bg-danger')
    end
  end
end
