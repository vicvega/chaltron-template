module Chaltron
  module UsersHelper
    def display_username(user, link: true)
      capture do
        if link
          concat link_to(user.username, user)
        else
          concat tag.span(user.username)
        end
        concat tag.span(I18n.t('chaltron.users.it_s_you'), class: 'badge badge-success ml-2') if user == current_user
        concat tag.span(t('chaltron.users.user_disabled'), class: 'badge badge-danger ml-2') if user.disabled?
      end
    end

    def display_side_filter_link(url, active, text, count)
      klass = 'list-group-item list-group-item-action'
      klass += ' active' if active

      badge_klass = 'badge badge-pill float-right'
      badge_klass += if active
                       ' badge-light'
                     else
                       ' badge-primary'
                     end

      link_to url, class: klass do
        tag.span(count, class: badge_klass) + text
      end
    end
  end
end
