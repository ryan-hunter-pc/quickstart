# This custom input will convert a collection select to a Choices.js input
# https://github.com/jshjohnson/Choices
#
# This depends on a StimulusJS `choices_controller.js` which integrates with Choices
class ChoicesInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_options
    input_html_options = super
    input_html_options[:data] ||= {}

    data_controllers = input_html_options[:data][:controller]&.split(' ') || []

    data_controllers << 'choices'

    new_data_attributes = {
      controller: data_controllers.join(' '),
    }

    input_html_options.merge(data: new_data_attributes)
  end
end
