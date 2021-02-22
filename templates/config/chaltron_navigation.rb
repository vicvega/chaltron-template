SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_class = 'justify-content-end'
    navigation.selected_class = 'active'

    if signed_in?
      if can?(:read, Chaltron::User) || can?(:read, Chaltron::Log)
        primary.item :admin, I18n.t('chaltron.menu.admin'), '#', link_html: { icon: 'cogs' } do |admin|
          if can?(:read, Chaltron::User)
            admin.item :users, I18n.t('chaltron.menu.users'), chaltron_users_path,
                       link_html: { icon: 'users' }, highlights_on: %r{/(users|ldap)(?!/self_(show|edit|update))}
          end
          if can?(:read, Chaltron::Log)
            admin.item :logs, I18n.t('chaltron.menu.logs'), chaltron_logs_path,
                       link_html: { icon: 'book' }, highlights_on: %r{/logs}
          end
        end
      end
      primary.item :logged, current_user.display_name.html_safe, '#',
                   html: { class: 'dropdown-menu-right' } do |user|
        user.item :self_edit, I18n.t('chaltron.menu.self_show'), self_show_chaltron_users_path,
                  link_html: { icon: 'user' }, highlights_on: %r{/self_(show|edit|update)}
        user.item :logout, 'Logout', destroy_user_session_path,
                  method: :delete, link_html: { icon: 'sign-out-alt' }
      end
    else
      primary.item :login, 'Login', new_user_session_path, link_html: { icon: 'sign-in-alt' }
    end
  end
end
