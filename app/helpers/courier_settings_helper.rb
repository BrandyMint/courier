module CourierSettingsHelper

  def courier_setting_link(user, template, service)
    return image_tag('disabled.png') if user.courier.disabled?(template, service)

    on = user.courier.on?(template, service)
    icon = image_tag(on ? 'on.png' : 'off.png')
    link_to(icon, courier_settings_set_path(:service=>service, :template=>template,
        :value=>(on ? 'off' : 'on')),
      :remote=>true, 'data-type'=>'html', :class=>:courier_checkbox
      )
  end
end
