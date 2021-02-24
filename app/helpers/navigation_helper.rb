module NavigationHelper
  def navbar_link_to(text, path, **options)
    classes = [options.delete(:class), 'navbar-link']
    options[:class] = classes.compact.join(' ')
    nav_link_to text, path, **options
  end

  def sidebar_link_to(text, path, **options)
    classes = [options.delete(:class), 'sidebar-link']
    options[:class] = classes.compact.join(' ')
    nav_link_to text, path, **options
  end

  def nav_link_to(text, path, **options)
    text = fa_icon(options.delete(:icon), text: text, icon_class: 'fa-fw') if options[:icon]
    classes = [options.delete(:class)]
    classes << 'active' if current_page?(path)
    options[:class] = classes.compact.join(' ')
    link_to text, path, **options
  end
end
