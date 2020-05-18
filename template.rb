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

# Setup thor source paths and ruby load paths
add_template_repository_to_source_path

print_banner

add_gems

after_bundle do
  stop_spring
end
