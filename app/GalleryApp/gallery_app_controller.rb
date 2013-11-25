require 'rho/rhocontroller'
require 'helpers/browser_helper'

class GalleryAppController < Rho::RhoController
  include BrowserHelper

  # GET /GalleryApp
  def index
    @gallery    = Gallery.find(@params['id'])
    $gallery_id = @params['id']
    render :action=>'index'
  end

  # GET /GalleryApp/{1}
  def show
    @galleryapp = GalleryApp.find(@params['id'])
    @review_hsh = @galleryapp.review_avg_hsh
    @review_avg = @galleryapp.review_avg
    if @galleryapp
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  def check_installed_apps
    @AppGalleries = GalleryApp.find(:all)      
    @AppGalleries.reject! { |app| app.select_build_link.nil? }
    
    num_installed = 0

    @AppGalleries.each do |app|
      build = app.select_build_link
      if build && build.executable_id && build.executable_id != ""
        if System::app_installed? build.executable_id
          app.downloading = "false"
          app.save
          app.state_install= "true"
        else
          #if error occurred during download timeout spinner
          #puts "before check is expired #{app.downloading == "true" and app.downloading and (Time.now.to_i > app.download_time.to_i)}****************************"
          if app.downloading == "true" and app.downloading and (Time.now.to_i > app.download_time.to_i)
            app.downloading = "false"
            app.download_time = ""
            app.save
            WebView.refresh
          end
          app.state_install= "false"
        end
      end

      num_installed = num_installed + 1 if app.state_install != "false"
    end

    #puts "num_installed: #{num_installed}, $num_installed: #{$num_installed}"
    
    should_update = 0

    if $first == false
      if num_installed != $num_installed
        should_update = 1
        # if num_installed > $num_installed
        #   Alert.show_popup "Application has been installed."
        # else
        #   Alert.show_popup "Application has been uninstalled."
        # end 
        WebView.refresh
      end
    end
    
    $first = false
    $num_installed = num_installed

    
    render :string => ::JSON.generate(should_update)
  end

  def install_app
    url=Rho::RhoSupport.url_decode(@params['url_install'])
    platform = System::get_property('platform')

    @gallery_app = GalleryApp.find(@params['id'])
    @gallery_app.downloading = "true"
    @gallery_app.download_time = Time.now.to_i + 300
    @gallery_app.save    
    
    if url == 'vpp'
      RedemptionCode.sync_redemption_codes(@params['id'],@gallery_app.build_install.object)
      render :action => :wait
    else
      if platform == 'APPLE' || platform == 'ANDROID'
        redirect :action => :index, :query=>{:id => $gallery_id}
      else
        redirect :action => :show,:query=>{:id=>@params['id'],:msg=>"Application is being installed",:btn_install_clicked=>'true'}
      end

      #download app in s3 for correct platform
      url = "itms-services://?action=download-manifest&url=#{url}"
      if platform == "APPLE"
        System.open_url(url)
      else
        download_from_s3(url,@gallery_app.object)
      end
    end
  end

  def download_from_s3(url,app_id)
    filename = url.split("/").last
    dwnldpath = Rho::RhoFile.join(Rho::Application.userFolder,filename)
    filepath = "file://#{dwnldpath}"

    downloadfileProps = Hash.new
    downloadfileProps["url"]=url
    downloadfileProps["filename"] = dwnldpath
    downloadfileProps["overwriteFile"] = true
    Rho::Network.downloadFile(downloadfileProps, url_for(:action => :download_file_callback),"&file=#{filepath}&id=#{app_id}")
  end

  def download_file_callback
    platform = System::get_property('platform')
    gallery_app = GalleryApp.find(@params['id'])
    if @params["status"] == "ok"
      System.app_install(@params['file'])
      gallery_app.state_install = true
    else
      Alert.show_popup "Download Failed"
    end
    gallery_app.download_time = ""
    gallery_app.downloading = "false"
    gallery_app.save
    WebView.refresh()
  end

  
  def uninstall_app
    @gallery_app = GalleryApp.find(@params['id'])
    @gallery_app.state_install="false"

    if System::get_property('platform') == 'APPLE' || System::get_property('platform') == 'ANDROID'
      redirect :action => :index, :query=>{:id => $gallery_id}
    else
      redirect :action => :show,:query=>{:id=>@params['id'],:msg=>"Application is being uninstalled",:btn_install_clicked=>'true'}
    end
    
    if System::app_installed?(@params['executable_id'])
      System::app_uninstall(@params['executable_id'])
    end
  end

  def run_app
    begin
      token = "rhogallery_app"
      token = @params['security_token'] if @params['security_token'] && @params['security_token'] != ''
      System.run_app(@params['executable_id'],"security_token="+token) if @params['executable_id']
    rescue Exception=>e
      puts "error running app #{e.message}"
    end  
    redirect :action => :index, :query => {:id => $gallery_id}
  end
end
