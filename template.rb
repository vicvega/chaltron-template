require "shellwords"
require "fileutils"
require "tmpdir"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.

# Add this template directory to ruby load path too, to require custom lib
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    tempdir = Dir.mktmpdir("chaltron-")
    source_paths.unshift(File.join(tempdir, "templates"))
    $LOAD_PATH.unshift(tempdir)

    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/vicvega/chaltron-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{chaltron-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.join(File.dirname(__FILE__), "templates"))
    $LOAD_PATH.unshift(File.dirname(__FILE__))
  end
end

def print_banner
  require "chaltron/banner"
  banner = Chaltron::Banner.new
  message = <<~TXT

      Be proud! You are running
    #{set_color(banner.sample, :blue, true)}
      aka #{set_color("Muffaster reloaded", :red)}

  TXT
  say message
end

def check_options
  rails = "rails #{Rails::VERSION::STRING}"
  say
  say "You are running #{set_color(rails, :red)}"

  if rails_old?
    say set_color("Shame on you!", :red, :on_white, :bold)
    exit_with_message("Update rails and try again...")
  end

  unless options["javascript"] == "esbuild" && options["css"] == "bootstrap"
    exit_with_message("You must specify --css=bootstrap and --javascript=esbuild options to run chaltron")
  end

  exit unless yes?("Are you sure you want to continue? [yes/NO]")
end

def add_gems
  gem "devise"
  gem "omniauth"
  gem "omniauth-rails_csrf_protection"
  gem "gitlab_omniauth-ldap", require: "omniauth-ldap", git: "https://gitlab.com/vicvega/omniauth-ldap"
  gem "cancancan"

  gem "device_detector"
  gem "pagy"
  gem "preserve"
  gem "simple_form"
  gem "rails-i18n"

  gem_group :development, :test do
    gem "factory_bot_rails"
    gem "faker"
    gem "standard"
    gem "standard-rails"
  end
  gsub_file "Gemfile", '# gem "image_processing"', 'gem "image_processing"'
end

def setup_database
  case options["database"]
  when "mysql"
    setup_mysql
  when "postgresql"
    setup_postgresql
  end
end

def ask_for_credential(default_user = "root")
  say
  say "Database credentials"
  @db_user = ask_with_default("Enter db username:", :blue, default_user)
  @db_password = ask_with_default("Enter db password:", :blue, "")
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

  gsub_file "config/database.yml", before, after
end

def setup_postgresql
  ask_for_credential(`whoami`.strip)

  text = <<-TXT
  username: #{@db_user}
  password: #{@db_password}
  TXT
  insert_into_file "config/database.yml", text, after: "#password:\n"
end

def install_bootstrap
  file = "app/assets/stylesheets/application.bootstrap.scss"
  inject_into_file file, "$font-size-base: .85rem;\n\n",
    before: "@import 'bootstrap/scss/bootstrap';"
end

def add_stimulus_controller
  directory "app/javascript/controllers/"
  rails_command "stimulus:manifest:update"
end

def add_assets
  directory "app/assets/images"
  copy_file "app/assets/stylesheets/chaltron.scss"

  file = "app/assets/stylesheets/application.bootstrap.scss"
  inject_into_file file, "@import './chaltron';\n"
end

def add_controllers
  directory "app/controllers/chaltron"
  directory "app/controllers/concerns/chaltron"
  copy_file "app/controllers/home_controller.rb"

  text = <<-TXT

  devise_group :user, contains: %i[local ldap]
  include Chaltron::Logging
  include Chaltron::ActiveLogin

  before_action :require_login, if: :current_user

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end
  TXT

  inject_into_file "app/controllers/application_controller.rb", text, before: "end"
end

def add_helpers
  directory "app/helpers"
  inject_into_file "app/helpers/application_helper.rb", "  include Pagy::Frontend\n", before: "end"
end

def add_views
  directory "app/views/chaltron"
  directory "app/views/devise"
  directory "app/views/home"
  directory "app/views/shared"

  layout = "app/views/layouts/application.html.erb"

  body = <<-BODY
  <%= render "shared/chaltron/navbar" %>
    <div id="flash" class="flash-container w-100 m-0 position-fixed top-0 text-center opacity-75">
      <%= render "shared/chaltron/flash" %>
    </div>
    <div id="content" class="container-fluid p-3 mx-auto">
      <%= yield %>
    </div>
    <div class="pt-4">
      <%= render "shared/chaltron/footer" %>
    </div>
  BODY
  gsub_file layout, "  <%= yield %>\n", body
end

def install_active_storage
  rails_command "active_storage:install"
end

def add_locales
  directory "config/locales", force: true
end

def add_javascript
  # add fontawesome
  run "yarn add @fortawesome/fontawesome-free"
  text = <<~JS

    import '@fortawesome/fontawesome-free/js/all';

  JS
  inject_into_file "app/javascript/application.js", text
  # remove bootstrap-icons
  run "yarn remove bootstrap-icons"
  gsub_file "app/assets/stylesheets/application.bootstrap.scss",
    "@import 'bootstrap-icons/font/bootstrap-icons';", ""
end

def add_users
  generate "devise:install"
  route "root to: \"home#index\""

  generate :devise, "Chaltron::User"

  devise_migration = Dir.glob("db/migrate/*").max_by { |f| File.mtime(f) }

  gsub_file devise_migration, "# t.integer  :sign_in_count, default: 0, null: false",
    "t.integer  :sign_in_count, default: 0, null: false"
  gsub_file devise_migration, "# t.datetime :current_sign_in_at", "t.datetime :current_sign_in_at"
  gsub_file devise_migration, "# t.datetime :last_sign_in_at", "t.datetime :last_sign_in_at"
  gsub_file devise_migration, "# t.string   :current_sign_in_ip", "t.string   :current_sign_in_ip"
  gsub_file devise_migration, "# t.string   :last_sign_in_ip", "t.string   :last_sign_in_ip"

  generate :migration, "add_fields_to_chaltron_users username:string:uniq " \
    "fullname department enabled:boolean extern_uid provider:string:index"

  gsub_file Dir.glob("db/migrate/*").max_by { |f| File.mtime(f) },
    "add_column :chaltron_users, :enabled, :boolean",
    "add_column :chaltron_users, :enabled, :boolean, default: true, null: false"

  generate :migration, "add_type_to_chaltron_users type remember_token"
end

def add_roles
  generate :model, "Chaltron::Role name:string:uniq"
  generate :migration, "CreateJoinTableRoleUser chaltron_roles chaltron_users"
end

def add_logs
  generate :model, "Chaltron::Log message:string{1000} severity:integer:index category:string:index"
end

def add_logins
  generate :model, "Chaltron::Login user:references device_id:string:uniq ip_address user_agent"
  file = Dir.glob("db/migrate/*").max_by { |f| File.mtime(f) }
  gsub_file file, "foreign_key: true", "foreign_key: {to_table: :chaltron_users}"
  %w[device_id ip_address].each do |field|
    gsub_file file, "t.string :#{field}", "t.string :#{field}, null: false"
  end
end

def setup_standard
  copy_file ".standard.yml"
end

def setup_devise
  gsub_file "config/initializers/devise.rb",
    "# config.authentication_keys = [:email]",
    "config.authentication_keys = [:login]"
end

def setup_chaltron
  directory "lib/chaltron"
  copy_file "lib/chaltron.rb"
  copy_file "config/initializers/chaltron.rb"
end

def setup_simple_form
  generate "simple_form:install --bootstrap"
end

def setup_pagy
  copy_file "config/initializers/pagy.rb"
end

def setup_application
  application do
    <<~RUBY
      # chaltron
      config.i18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")
      config.action_mailer.default_url_options = {host: "localhost", port: 3000}
    RUBY
  end
end

def add_routes
  Array(1..10).each do |x|
    route "get \"home/test#{x}\""
  end
  route 'get "home/index"'

  routes = <<-ROUTES

  devise_for :local, class_name: "Chaltron::LocalUser", path: "users", controllers: {
    sessions: "chaltron/sessions"
  }
  devise_for :ldap, class_name: "Chaltron::LdapUser", controllers: {
    omniauth_callbacks: "chaltron/omniauth_callbacks"
  }

  namespace :chaltron do
    resources :logs, only: %i[index show]
    resources :logins, only: :destroy

    resources :users, except: %i[new create] do
      member do
        post "enable"
        post "disable"
      end
    end
    resources :local_users, only: %i[new create]

    get "self_user/show"
    get "self_user/edit"
    get "self_user/change_password"
    patch "self_user/update"
    patch "self_user/update_password"

    # search and create LDAP users
    if Devise.omniauth_providers.include?(:ldap) && !Chaltron.ldap_allow_all
      get "ldap/search" => "ldap#search"
      post "ldap/multi_new" => "ldap#multi_new"
      post "ldap/multi_create" => "ldap#multi_create"
    end
  end
  ROUTES

  gsub_file "config/routes.rb", '  devise_for :users, class_name: "Chaltron::User"', routes
end

def add_models
  directory "app/models", force: true
  # self.table_name_prefix is defined in lib/chaltron.rb
  run 'rm -rf "app/models/chaltron.rb"'
end

def add_tests
  directory "test", force: true
  run 'rm -f "test/factories/chaltron/users.rb"'
end

def add_seeds
  append_file "db/seeds.rb" do
    <<~RUBY

      # standard:disable Rails/SaveBang
      Chaltron::Role.create(name: :admin)
      Chaltron::Role.create(name: :user_admin)

      Chaltron::LocalUser.create do |u|
        u.username = "bella"
        u.fullname = "Bellatrix Lestrange"
        u.email = "bellatrix.lestrange@azkaban.co.uk"
        u.password = "password.1"
        u.password_confirmation = "password.1"
        u.roles = Chaltron::Role.all
      end
      # standard:enable Rails/SaveBang
    RUBY
  end
end

def finalize
  rails_command "db:create"
  rails_command "db:migrate"
  rails_command "db:seed"

  if @db_user
    say
    say "Be warned!", :red
    say "You have credentials stored in clear text in " \
      "config/database.yml file. ⛔️\nRemember this before " \
      "sharing the project!!"
  end
  say
  say "👍 Chaltron template successfully applied! ✌", :green
  say
  say "And now:"
  say " - cd #{app_name}"
  say " - ./bin/dev"
  say
  say "Enjoy! 🍺🍺"
end

def rails_old?
  return true if Rails::VERSION::MAJOR < 7
  Rails::VERSION::MINOR < 1
end

def exit_with_message(message)
  say set_color(message, :red, :bold)
  exit
end

# Setup thor source paths and ruby load paths
add_template_repository_to_source_path

print_banner
check_options
add_gems
after_bundle do
  setup_database

  install_bootstrap
  add_stimulus_controller
  add_assets
  add_controllers
  add_helpers
  add_views
  add_javascript
  install_active_storage

  add_users
  add_roles
  add_logs
  add_logins

  setup_standard
  setup_devise
  setup_chaltron
  setup_simple_form
  setup_pagy
  setup_application

  add_locales
  add_routes
  add_models
  add_tests
  add_seeds

  finalize
end
