module FontAwesomeHelper
  def fa_icon(icon, options = {})
    text = options.delete(:text)
    text_classes = [options.delete(:text_class)].flatten.compact
    icon_on_right = options.delete(:right)
    icon_spacing_class = icon_on_right ? 'ml-2' : 'mr-2' if text.present?
    icon_prefix_class = options.delete(:brand) ? 'fab' : 'fas'
    icon_classes = [icon_prefix_class, "fa-#{icon}", icon_spacing_class,
                    options.delete(:icon_class)].flatten.compact

    components = []
    components << content_tag(:i, nil, class: icon_classes.join(' '))
    components << content_tag(:span, text, class: text_classes.join(' ')) if text.present?
    components.reverse! if icon_on_right == true
    components.join.html_safe
  end
end
