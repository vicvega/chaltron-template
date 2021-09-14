module Chaltron
  module UsersHelper
    def display_username(user, link: true)
      capture do
        if link
          concat link_to(user.username, user)
        else
          concat tag.span(user.username)
        end
        concat tag.span(I18n.t('chaltron.users.it_s_you'), class: 'badge bg-success ms-2') if user == current_user
        concat tag.span(t('chaltron.users.user_disabled'), class: 'badge bg-danger ms-2') if user.disabled?
      end
    end
  end
end
