module BrowserHelper

  def placeholder(label=nil)
    "placeholder='#{label}'" if platform == 'apple'
  end

  def platform
    System::get_property('platform').downcase
  end

  def selected(option_value,object_value)
    "selected=\"yes\"" if option_value == object_value
  end

  def checked(option_value,object_value)
    "checked=\"yes\"" if option_value == object_value
  end

  def galleryapp_url(galleryapp,force_uninstall=false)
    url = ""
    if galleryapp.downloading == "true"
      url = "#"
    else
      state_install = force_uninstall == "true" ? "false" : galleryapp.state_install 
      case state_install
      when "true"
        url = "/app/GalleryApp/run_app?security_token=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.security_token)}&bundle_id=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.bundle_id)}&id=#{galleryapp.object}"
      when "false"
        url = "/app/GalleryApp/install_app?url_install=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.url)}&id=#{galleryapp.object}"
      when "maybe"
        url = "/app/GalleryApp/uninstall_app?bundle_id=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.bundle_id)}&id=#{galleryapp.object}"
      else
        url = "/app/GalleryApp/install_app?url_install=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.url)}&id=#{galleryapp.object}"
      end
    end
    url
  end

  def btn_type(galleryapp,force_uninstall=false)
    state_install = force_uninstall == "true" ? "false" : galleryapp.state_install
    btn = "btn "
    if galleryapp.downloading == "true"
      btn += "btn-warning blink "
      name = "Downloading"
    else
      case state_install
      when "true"
        btn += "btn-success "
        name = "Open"
      when "false"
        btn += "btn-default "
        name = "Install"
      when "maybe"
        btn += "btn-danger "
        name = "Uninstall"
      else
        btn += "btn-default "
        name = "Install"
      end
    end
    btn += "btn-xs"
    return btn,name
  end

end