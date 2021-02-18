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
  gem 'devise'
  gem 'omniauth'
  gem 'omniauth-rails_csrf_protection'
  gem 'gitlab_omniauth-ldap', require: 'omniauth-ldap'
  gem 'cancancan'

  gem 'autoprefixer-rails'
  gem 'simple-navigation'
  gem 'bootstrap_form'
  gem 'rails-i18n'
  gem 'ajax-datatables-rails'

  gem_group :development do
    gem 'foreman'
  end

  gem_group :development, :test do
    gem 'factory_bot_rails'
    gem 'ffaker'
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

def add_assets
  directory 'app/assets/images'
  directory 'app/assets/stylesheets'
end

def add_controllers
  directory 'app/controllers/chaltron'
  directory 'app/controllers/concerns/chaltron'
  copy_file 'app/controllers/home_controller.rb'
  inject_into_file 'app/controllers/application_controller.rb', "  include Chaltron::Logging\n", before: 'end'
end

def add_datatables
  directory 'app/datatables'
end

def add_helpers
  directory 'app/helpers'
end

def add_views
  directory 'app/views/chaltron'
  directory 'app/views/devise'
  directory 'app/views/home'

  template 'app/views/layouts/application.html.erb.tt', force: true
  copy_file 'app/views/layouts/_flash.html.erb'
  copy_file 'app/views/layouts/_footer.html.erb'
  copy_file 'app/views/layouts/_navbar.html.erb'

  copy_file 'config/navigation.rb'
  copy_file 'config/chaltron_navigation.rb'
end

def add_locales
  directory 'config/locales', force: true
end

def add_javascript
  run 'yarn add jquery popper.js bootstrap @fortawesome/fontawesome-free ' \
    'nprogress datatables.net-bs4 datatables.net-responsive-bs4'

  directory 'app/javascript/chaltron'
  directory 'app/javascript/stylesheets'
  copy_file 'app/javascript/packs/application.js', force: true

  text = <<~JS
    const webpack = require('webpack');

    environment.plugins.append('Provide',
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['popper.js', 'default']
      })
    );

  JS
  inject_into_file 'config/webpack/environment.js', text, before: 'module.exports = environment'
end

def add_users
  generate 'devise:install'
  route "root to: 'home#index'"

  generate :devise, 'User'

  before = <<-BEF
      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip
  BEF

  after = <<-AFT
      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
  AFT

  gsub_file Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) }, before, after

  generate :migration, 'add_fields_to_users username:string:uniq ' \
    'fullname department enabled:boolean provider extern_uid'

  gsub_file Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) },
            'add_column :users, :enabled, :boolean',
            'add_column :users, :enabled, :boolean, default: true'
end

def add_roles
  generate :model, 'Role name:string:uniq'
  generate :migration, 'CreateJoinTableRoleUser roles users'
end

def add_logs
  generate :model, 'Log message:string{1000} severity category'
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

def setup_foreman
  copy_file 'Procfile'
end

def setup_application
  application do
    <<~RUBY
      # chaltron
      config.autoload_paths << File.join([Rails.root], %w[app models chaltron])
      config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
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

  devise_for :users, controllers: { omniauth_callbacks: 'chaltron/omniauth_callbacks' }

  resources :logs, controller: 'chaltron/logs', only: [:index, :show]

  resources :users, controller: 'chaltron/users' do
    collection do
      get   'self_show'
      get   'self_edit'
      patch 'self_update'
    end
    member do
      get 'enable'
      get 'disable'
    end
  end

  # search and create LDAP users
  if Devise.omniauth_providers.include?(:ldap) and !Chaltron.ldap_allow_all
    get   'ldap/search'       => 'chaltron/ldap#search'
    post  'ldap/multi_new'    => 'chaltron/ldap#multi_new'
    post  'ldap/multi_create' => 'chaltron/ldap#multi_create'
  end
  ROUTES

  gsub_file 'config/routes.rb', '  devise_for :users', routes
end

def add_models
  # move models under chaltron directory
  run 'rm -f "app/models/user.rb"'
  run 'rm -f "app/models/log.rb"'
  run 'rm -f "app/models/role.rb"'
  directory 'app/models', force: true
end

def add_scaffold_templates
  directory 'lib/templates'
end

def add_tests
  directory 'test', force: true
  run 'rm -rf "test/fixtures"'
end

def add_seeds
  append_file 'db/seeds.rb' do
    <<~RUBY

      Role.create(name: :admin)
      Role.create(name: :user_admin)

      User.create do |u|
        u.username              = 'bella'
        u.fullname              = 'Bellatrix Lestrange'
        u.email                 = 'bellatrix.lestrange@azkaban.co.uk'
        u.password              = 'password.1'
        u.password_confirmation = 'password.1'
        u.roles                 = Role.all
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
  say ' - foreman start'
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

  add_assets
  add_controllers
  add_datatables
  add_helpers
  add_views
  add_javascript

  add_users
  add_roles
  add_logs

  setup_devise
  setup_warden
  setup_chaltron
  setup_foreman
  setup_application

  add_locales
  add_routes
  add_models
  add_scaffold_templates
  add_tests
  add_seeds

  finalize
end
