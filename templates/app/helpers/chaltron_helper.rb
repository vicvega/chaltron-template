module ChaltronHelper
  def ldap_enabled?
    Devise.omniauth_providers.include? :ldap
  end

  def icon(style, name, text = nil, html_options = {})
    if text.is_a?(Hash)
      html_options = text
      text = nil
    end
    content_class = "#{style} fa-#{name}"
    content_class << " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class

    html = tag.i(nil, html_options)
    html << ' ' << text.to_s if text.present?
    html
  end

  def back_link(opts = {})
    klass = opts[:class] || 'btn btn-primary'
    text  = opts[:text]  || t('chaltron.common.back')
    ic    = opts[:icon]  || 'arrow-left '

    link_to :back, class: klass do
      icon(:fas, ic, text)
    end
  end

  def custom_checkbox(options)
    id = options.delete(:id)
    klass = options.delete(:class)
    tag.div(class: 'custom-control custom-checkbox') do
      check_box_tag('checkbox', nil, nil, options.merge(id: id, class: "custom-control-input d-none #{klass}")) +
        label_tag(id, '', class: 'custom-control-label d-block', for: id)
    end
  end

  #
  # Flash messages
  #
  def bootstrap_class_for(flash_type)
    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }[flash_type] || flash_type.to_s
  end

  def flash_message(message, type)
    tag.div(message, class: "alert #{bootstrap_class_for(type)} rounded-0") do
      tag.strong "#{I18n.t(['chaltron', 'flash', type].join('.'))}: #{message}"
    end
  end

  #
  # Get current revision
  #
  def revision
    version_file = Rails.root.join('REVISION')
    return unless File.exist?(version_file)

    v = IO.read(version_file).strip
    v.presence
  end
end
