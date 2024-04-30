def list_start?(components, index)
  return true if index.zero?

  return true if components[index - 1]['componentType'] != components[index]['componentType']

  false
end

def list_end?(components, index)
  return true if index == components.size - 1

  return true if components[index + 1]['componentType'] != components[index]['componentType']

  false
end

def content_type(filename)
  return 'jpeg' if filename =~ /\.(jpeg|jpg)$/i

  'png'
end

def create_html_element(components, index)
  html_string = ''
  component = components[index]

  case component['componentType']
  when 'Text'
    html_string += "<p>#{component['content']}</p>\n"
  when 'Olist'
    html_string += '<ol>' if list_start?(components, index)
    html_string += "<li>#{component['content']}</li>"
    html_string += "</ol>\n" if list_end?(components, index)
  when 'Ulist'
    html_string += '<ul>' if list_start?(components, index)
    html_string += "<li>#{component['content']}</li>"
    html_string += "</ul>\n" if list_end?(components, index)
  when 'Upload'
    src = component['component_attachment']['url']
    filename = component['component_attachment']['filename']
    filesize = component['component_attachment']['filesize']
    content_type = "image/#{content_type(filename)}"
    width = component['component_attachment']['dimensions']['width']
    height = component['component_attachment']['dimensions']['height']
    html_string = "<action-text-attachment content-type=\"#{content_type}\" url=\"#{src}\" filename=\"#{filename}\" filesize=\"#{filesize}\" width=\"#{width}\" height=\"#{height}\" previewable=\"true\" presentation=\"gallery\"><figure class=\"attachment attachment--preview attachment--jpeg\"> <img src=\"#{src}\" /> <figcaption class=\"attachment__caption\"> <span class=\"attachment__name\">#{filename}</span> </figcaption> </figure></action-text-attachment>\n"
  else
    raise "Invalid element #{index} #{component['componentType']}"
  end
  html_string
end

def action_text_string(components)
  return if components.blank?

  res_string = ''
  components.each_with_index do |_component, index|
    res_string += create_html_element(components, index)
  end
  res_string
end

namespace :consultation do
  desc 'Convert Page component in consultation to action text'
  task convert_page_to_action_text: :environment do
    Consultation.all.each do |consultation|
      english_summary = action_text_string(consultation.page&.components)
      hindi_summary = action_text_string(consultation.consultation_hindi_summary&.page&.components)
      consultation.update!(english_summary: english_summary)
      consultation.update!(hindi_summary: hindi_summary)
    end
  end
end
