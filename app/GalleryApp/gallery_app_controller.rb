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
            #puts "***********************************************"
            #puts "reseting install button *******************"
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
    @state_install = @gallery_app.state_install
    @gallery_app.state_install=true

    if @state_install == "false"
      @gallery_app.downloading = "true"
      @gallery_app.download_time = Time.now.to_i + 300
      @gallery_app.save
    end
    
    if url == 'vpp'
      RedemptionCode.sync_redemption_codes(@params['id'],@gallery_app.build_install.object)
      render :action => :wait
    else
      if platform == 'APPLE' ||platform == 'ANDROID'
        redirect :action => :index, :query=>{:id => $gallery_id}
      else
        redirect :action => :show,:query=>{:id=>@params['id'],:msg=>"Application is being installed",:btn_install_clicked=>'true'}
      end
    
      #download app in s3 for correct platform
      if platform == 'APPLE'
        $iphone_url = "itms-services://?action=download-manifest&url=#{url}"
        System.open_url($iphone_url)
        $iphone_url = nil
      elsif platform != 'APPLE' && platform != 'ANDROID' && platform != 'WINDOWS_DESKTOP'
        System.open_url(url)
      elsif platform == 'ANDROID' || platform == 'WINDOWS_DESKTOP'
        System.app_install(url)
      end
    end
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
