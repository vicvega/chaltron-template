module Chaltron
  module LdapHelper
    def display_entry_name(entry)
      capture do
        concat entry.name
        if User.exists?(username: entry.username)
          concat tag.span(I18n.t('chaltron.users.already_present'), class: 'badge badge-danger ml-1')
        end
      end
    end

    def display_entry_email(entry)
      entry.email.presence || tag.span(I18n.t('chaltron.users.missing_field'), class: 'badge badge-danger')
    end
  end
end
