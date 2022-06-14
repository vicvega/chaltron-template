require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:overflow] = :last_page
Pagy::I18n.load(locale: 'it', filepath: Rails.root.join('config/locales/pagy.it.yml'))
