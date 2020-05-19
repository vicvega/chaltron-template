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
    $:.unshift(tempdir)

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
    $:.unshift(File.dirname(__FILE__))
  end
end

def print_banner
  require 'chaltron/banner'
  banner = Chaltron::Banner.new
  message = <<-TXT

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

  gem 'foreman'

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

  before =<<-END
  username: root
  password:
END

after =<<-END
  username: #{@db_user}
  password: #{@db_password}
END

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
  inject_into_file 'app/controllers/application_controller.rb',
    "  include Chaltron::Logging\n", before: 'end'
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

def add_javascript
  run 'yarn add jquery popper.js bootstrap @fortawesome/fontawesome-free ' \
    'nprogress imports-loader datatables.net-bs4 datatables.net-responsive-bs4'
end

def setup_users_and_roles
end

def setup_ajax_datatables
end

def add_logs
end

def add_models
  directory 'app/models'
end

def add_tests
end

def add_scaffold_template
end

def setup_locale
end

def setup_chaltron
end

def finalize
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


  finalize
end
