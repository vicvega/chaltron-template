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

    html = tag.i(nil, **html_options)
    html << ' ' << text.to_s if text.present?
    html
  end

  def custom_checkbox(options)
    id = options.delete(:id)
    klass = options.delete(:class)
    name = options.delete(:name) || id
    value = options.delete(:value) || 1
    checked = options.delete(:checked) || false
    div_class = options.delete(:div_class)
    label = options.delete(:label) || ''
    tag.div(class: "form-check #{div_class}") do
      check_box_tag(name, value, checked, options.merge(id: id, class: "form-check-input #{klass}")) +
        label_tag(id, label, class: 'form-check-label', for: id)
    end
  end

  #
  # Flash messages
  #
  def bootstrap_class_for(flash_type)
    {
      'success' => 'alert-success',
      'error' => 'alert-danger',
      'alert' => 'alert-warning',
      'notice' => 'alert-info'
    }[flash_type] || flash_type.to_s
  end

  def render_turbo_stream_flash_messages
    turbo_stream.prepend 'flash', partial: 'shared/flash'
  end

  #
  # Get current revision
  #
  def revision
    version_file = Rails.root.join('REVISION')
    return unless File.exist?(version_file)

    v = File.read(version_file).strip
    v.presence
  end

  def display_side_filter_link(url, active, text, count, id)
    return unless count.positive?

    klass = 'list-group-item list-group-item-action'
    klass += ' active' if active

    badge_klass = 'badge rounded-pill float-end'
    badge_klass += if active
                     ' bg-light text-dark'
                   else
                     ' bg-primary'
                   end

    link_to url, class: klass, id: "filter_#{id}_link" do
      tag.span(number_with_delimiter(count), class: badge_klass, id: "filter_#{id}_count") + text
    end
  end

  def sortable(column, options = {})
    title = options.fetch(:label, column.to_s.titleize)
    remote = options.fetch(:remote, false)
    data = options.fetch(:data, {})
    direction = column.to_s == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'

    params = request.params.merge(sort: column, direction: direction, page: nil)

    if column.to_s == sort_column
      link_to(params, class: 'current', remote: remote, data: data) do
        tag.span class: 'text-body' do
          icon :fas, sort_direction == 'asc' ? 'sort-up' : 'sort-down', title
        end
      end
    else
      link_to(params, remote: remote, data: data) do
        tag.span class: 'text-secondary' do
          icon :fas, 'sort', title
        end
      end
    end
  end
end
