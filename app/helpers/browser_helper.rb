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

  def galleryapp_url(galleryapp)
    url = ""
    if galleryapp.downloading == "true"
      url = "#"
    else
      case galleryapp.state_install
      when "true"
        url = "/app/GalleryApp/run_app?security_token=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.security_token)}&executable_id=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.executable_id)}&id=#{galleryapp.object}"
      when "false"
        url = "/app/GalleryApp/install_app?url_install=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.url)}&id=#{galleryapp.object}"
      when "maybe"
        url = "/app/GalleryApp/uninstall_app?executable_id=#{Rho::RhoSupport.url_encode(galleryapp.select_build_link.executable_id)}&id=#{galleryapp.object}"
      end
    end
    url
  end

  def btn_type(galleryapp)
    state_install = galleryapp.state_install
    btn = "btn "
    if galleryapp.downloading == "true"
      btn += "btn-warning "
      name = "downloading..."
    else
      case state_install
      when "true"
        btn += "btn-success "
        name = "open"
      when "false"
        btn += "btn-default "
        name = "install"
      when "maybe"
        btn += "btn-danger "
        name = "uninstall"
      end
    end
    btn += "btn-xs"
    return btn,name
  end

end