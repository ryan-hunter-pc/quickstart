module ButtonHelper
  def icon_button(path, options = {})
    icon = options.delete(:icon) || 'info'
    text = options.delete(:text)
    color = options.delete(:color) || 'default'
    classes = ['btn', "btn-#{color}", options.delete(:class)]
    class_string = classes.compact.join(' ')
    options[:class] = class_string
    link_to fa_icon(icon, text: text), path, options
  end

  def back_button(options = {})
    path = options[:path] ||= :back
    options[:icon] ||= 'chevron-left'
    options[:text] ||= 'Back'
    options[:color] ||= 'grey-light'
    icon_button path, options
  end

  def cancel_button(options = {})
    path = options[:path] ||= :back
    options[:icon] ||= 'times'
    options[:text] ||= 'Cancel'
    options[:color] ||= 'grey-light'
    icon_button path, options
  end

  def new_button(path, options = {})
    options[:icon] ||= 'plus'
    options[:color] ||= 'primary'
    icon_button path, options
  end

  def edit_button(path, options = {})
    options[:icon] ||= 'pencil-alt'
    options[:text] ||= 'Edit'
    options[:color] ||= 'warning'
    icon_button path, options
  end

  def icon_link(path, options = {})
    icon = options.delete(:icon) || 'info'
    text = options.delete(:text)
    color = options.delete(:color) || 'info'
    classes = ["text-#{color}", options.delete(:class)]
    class_string = classes.compact.join(' ')
    options[:class] = class_string
    link_to fa_icon(icon, text: text), path, options
  end

  def edit_link_in_table(path, options = {})
    options[:icon] ||= 'pencil-alt'
    options[:text] ||= 'Edit'
    options[:color] ||= 'info'
    icon_link path, options
  end

  def delete_link_in_table(path, options = {})
    options[:icon] ||= 'trash'
    options[:text] ||= 'Delete'
    options[:color] ||= 'danger'
    options[:method] ||= :delete
    options[:data] = (options[:data] || {}).merge!({ confirm: "Are you sure you want to delete this record?" })
    icon_link path, options
  end

  def submit_button(options = {})
    f = options.delete(:f)

    icon = options.delete(:icon)
    icon = 'check' if icon.nil? # allow passing false for no icon
    icon_right = options.delete(:icon_right)

    text = options.delete(:text)
    text = "Save #{f.object.class}" if text.nil? # allow passing false for no text

    if icon
      content = fa_icon(icon, text: text, right: icon_right)
    else
      content = text
    end

    color = options.delete(:color) || 'primary'
    name = options.delete(:name) || 'button'
    value = options.delete(:value) || text
    id = options.delete(:id)

    classes = ['btn', "btn-#{color}", options.delete(:class)]
    class_string = classes.compact.join(' ')

    data_hash = options.delete(:data) || {}
    data_hash[:disable_with] ||= fa_icon('spinner', icon_class: 'fa-spin')

    if f
      f.button :button,
               content,
               type: :submit,
               name: name,
               value: value,
               id: id,
               class: class_string,
               data: data_hash
    else
      button_tag content,
                 type: :submit,
                 name: name,
                 value: value,
                 id: id,
                 class: class_string,
                 data: data_hash
    end
  end
end
