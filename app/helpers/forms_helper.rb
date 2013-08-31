module FormsHelper

  def form_title(form)
    "#{form.title} (#{form.number})"
  end
  
  def form_input(f, form_field)
    f.input form_field.name.to_sym,
      :label => form_field.label || form_field.name.humanize, 
      :collection => form_field.options, 
      :required => form_field.is_required,
      :hint => form_field.description,
      :as => form_field.formtastic_field_type.to_sym
  end
  
  def omb_info(form)
    link_to "Form Approved OMB##{form.omb_control_number} | Expires at #{form.omb_expiration_date}", "http://www.reginfo.gov/public/do/PRAViewICR?ref_nbr=#{form.icr_reference_number}"
  end
end
