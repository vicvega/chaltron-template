require 'shellwords'
require 'fileutils'

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.

# Add this template directory to ruby load path too, to require custom lib
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    tempdir = Dir.mktmpdir('chaltron-')
    source_paths.unshift(File.join(tempdir, 'templates'))
    $LOAD_PATH.unshift(tempdir)

    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/vicvega/chaltron-template.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{chaltron-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.join(File.dirname(__FILE__), 'templates'))
    $LOAD_PATH.unshift(File.dirname(__FILE__))
  end
end

def print_banner
  require 'chaltron/banner'
  banner = Chaltron::Banner.new
  message = <<~TXT

    Be proud! You are running
  #{set_color(banner.sample, :blue, true)}
    aka #{set_color('Muffaster reloaded', :red)}

  TXT
  say message
  exit unless yes?('Are you sure you want to continue? [yes/NO]')
end

def add_gems
  gem 'jsbundling-rails'
  gem 'devise'
  gem 'omniauth'
  gem 'omniauth-rails_csrf_protection'
  gem 'gitlab_omniauth-ldap', require: 'omniauth-ldap'
  gem 'cancancan'

  gem 'simple_form'
  gem 'rails-i18n'
  gem 'pagy'

  gem_group :development do
    gem 'foreman'
  end

  gem_group :development, :test do
    gem 'factory_bot_rails'
    gem 'faker'
  end
end

def stop_spring
  run 'spring stop'
end

def setup_database
  case options['database']
  when 'mysql'
    setup_mysql
  end
end

def ask_for_credential
  say
  say 'Database credentials'
  @db_user = ask_with_default('Enter db username:', :blue, 'root')
  @db_password = ask_with_default('Enter db password:', :blue, '')
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?

  question = (question + " [#{default}]")
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def setup_mysql
  ask_for_credential

  before = <<-BEF
  username: root
  password:
  BEF

  after = <<-AFT
  username: #{@db_user}
  password: #{@db_password}
  AFT

  gsub_file 'config/database.yml', before, after
end

def install_jsbundling
  rails_command 'javascript:install:webpack'
end

def add_assets
  directory 'app/assets/images'
  directory 'app/assets/stylesheets'

  append_file 'config/initializers/assets.rb' do
    <<~RUBY

      # Add Yarn node_modules folder to the asset load path.
      Rails.application.config.assets.paths << Rails.root.join('node_modules')
    RUBY
  end
end

def add_controllers
  directory 'app/controllers/chaltron'
  directory 'app/controllers/concerns/chaltron'
  copy_file 'app/controllers/home_controller.rb'
  inject_into_file 'app/controllers/application_controller.rb', "  include Chaltron::Logging\n", before: 'end'
end

def add_helpers
  directory 'app/helpers'
  inject_into_file 'app/helpers/application_helper.rb', "  include Pagy::Frontend\n", before: 'end'
end

def add_views
  directory 'app/views/chaltron'
  directory 'app/views/devise'
  directory 'app/views/home'

  template 'app/views/layouts/application.html.erb.tt', force: true
  copy_file 'app/views/layouts/_flash.html.erb'
  copy_file 'app/views/layouts/_footer.html.erb'
  copy_file 'app/views/layouts/_navbar.html.erb'
end

def add_locales
  directory 'config/locales', force: true
end

def add_javascript
  run 'yarn add @rails/actioncable @rails/activestorage @rails/ujs turbolinks ' \
      '@popperjs/core bootstrap @fortawesome/fontawesome-free'

  directory 'app/javascript', force: true
end

def add_users
  generate 'devise:install'
  route "root to: 'home#index'"

  generate :devise, 'Chaltron::User'

  devise_migration = Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) }

  gsub_file devise_migration, '# t.integer  :sign_in_count, default: 0, null: false',
            't.integer  :sign_in_count, default: 0, null: false'
  gsub_file devise_migration, '# t.datetime :current_sign_in_at', 't.datetime :current_sign_in_at'
  gsub_file devise_migration, '# t.datetime :last_sign_in_at',    't.datetime :last_sign_in_at'
  gsub_file devise_migration, '# t.string   :current_sign_in_ip', 't.string   :current_sign_in_ip'
  gsub_file devise_migration, '# t.string   :last_sign_in_ip',    't.string   :last_sign_in_ip'

  generate :migration, 'add_fields_to_chaltron_users username:string:uniq ' \
    'fullname department enabled:boolean provider extern_uid'

  gsub_file Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) },
            'add_column :chaltron_users, :enabled, :boolean',
            'add_column :chaltron_users, :enabled, :boolean, default: true'
end

def add_roles
  generate :model, 'Chaltron::Role name:string:uniq'
  generate :migration, 'CreateJoinTableRoleUser chaltron_roles chaltron_users'
end

def add_logs
  generate :model, 'Chaltron::Log message:string{1000} severity category'
end

def setup_devise
  gsub_file 'config/initializers/devise.rb',
            '# config.authentication_keys = [:email]',
            'config.authentication_keys = [:login]'
end

def setup_warden
  copy_file 'config/initializers/warden.rb'
end

def setup_chaltron
  directory 'lib/chaltron'
  copy_file 'lib/chaltron.rb'
  copy_file 'config/initializers/chaltron.rb'
end

def setup_simple_form
  generate 'simple_form:install --bootstrap'
  file = 'config/initializers/simple_form_bootstrap.rb'

  gsub_file file,
            "config.wrappers :horizontal_form, tag: 'div', class: 'form-group row'",
            "config.wrappers :horizontal_form, tag: 'div', class: 'form-group row mb-3'"

  gsub_file file,
            "config.wrappers :vertical_form, tag: 'div', class: 'form-group'",
            "config.wrappers :vertical_form, tag: 'div', class: 'form-group mb-3'"

  gsub_file file,
            "config.wrappers :vertical_collection_inline, item_wrapper_class: 'form-check form-check-inline', item_label_class: 'form-check-label', tag: 'fieldset', class: 'form-group'",
            "config.wrappers :vertical_collection_inline, item_wrapper_class: 'form-check form-check-inline', item_label_class: 'form-check-label', tag: 'fieldset', class: 'form-group mb-3'"
end

def setup_pagy
  copy_file 'config/initializers/pagy.rb'
end

def setup_foreman
  copy_file 'Procfile'
end

def setup_application
  application do
    <<~RUBY
      # chaltron
      config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.{rb,yml}')]
      config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    RUBY
  end
end

def add_routes
  Array(1..10).each do |x|
    route "get 'home/test#{x}'"
  end
  route "get 'home/index'"

  routes = <<-ROUTES

  devise_for :users, controllers: { omniauth_callbacks: 'chaltron/omniauth_callbacks' }, class_name: 'Chaltron::User'

  namespace :chaltron do
    resources :logs, only: %i[index show]

    resources :users do
      member do
        get 'enable'
        get 'disable'
      end
    end

    get   'self_user/show'
    get   'self_user/edit'
    get   'self_user/change_password'
    patch 'self_user/update'

    # search and create LDAP users
    if Devise.omniauth_providers.include?(:ldap) && !Chaltron.ldap_allow_all
      get   'ldap/search'       => 'ldap#search'
      post  'ldap/multi_new'    => 'ldap#multi_new'
      post  'ldap/multi_create' => 'ldap#multi_create'
    end
  end
  ROUTES

  gsub_file 'config/routes.rb', '  devise_for :users, class_name: "Chaltron::User"', routes
end

def add_models
  directory 'app/models', force: true
  # self.table_name_prefix is defined in lib/chaltron.rb
  run 'rm -rf "app/models/chaltron.rb"'
end

def add_tests
  directory 'test', force: true
  run 'rm -rf "test/fixtures"'
end

def add_seeds
  append_file 'db/seeds.rb' do
    <<~RUBY

      Chaltron::Role.create(name: :admin)
      Chaltron::Role.create(name: :user_admin)

      Chaltron::User.create do |u|
        u.username              = 'bella'
        u.fullname              = 'Bellatrix Lestrange'
        u.email                 = 'bellatrix.lestrange@azkaban.co.uk'
        u.password              = 'password.1'
        u.password_confirmation = 'password.1'
        u.roles                 = Chaltron::Role.all
      end
    RUBY
  end
end

def finalize
  rails_command 'db:create'
  rails_command 'db:migrate'
  rails_command 'db:seed'

  if @db_password
    say
    say 'Be warned!', :red
    say 'You have a password stored in clear text in ' \
      "config/database.yml file. ⛔️\nRemember this before " \
      'sharing the project!!'
  end
  say
  say '👍 Chaltron template successfully applied! ✌', :green
  say
  say 'And now:'
  say " - cd #{app_name}"
  say ' - ./bin/dev'
  say
  say 'Enjoy! 🍺🍺'
end

# Setup thor source paths and ruby load paths
add_template_repository_to_source_path

print_banner
add_gems
after_bundle do
  stop_spring
  setup_database

  install_jsbundling
  add_assets
  add_controllers
  add_helpers
  add_views
  add_javascript

  add_users
  add_roles
  add_logs

  setup_devise
  setup_warden
  setup_chaltron
  setup_simple_form
  setup_pagy
  setup_foreman
  setup_application

  add_locales
  add_routes
  add_models
  add_tests
  add_seeds

  finalize
end
