require 'rho/rhocontroller'
require 'helpers/browser_helper'

class GalleryAppController < Rho::RhoController
  include BrowserHelper

  # GET /GalleryApp
  def index
    id = @params['id'] || Gallery.curr_gallery
    @gallery    = Gallery.find(id)
    Gallery.curr_gallery = id
    render :action=>'index', :back => "/app/Gallery?id=#{@params['id']}"
  end

  # GET /GalleryApp/{1}
  def show
    @galleryapp = GalleryApp.find(@params['id'])
    @force_uninstall = @params['uninstall']
    @galleryapp.review_avg_hsh
    @galleryapp.review_avg
    if @galleryapp
      render :action => :show, :back => url_for(:action => :index,:id=>@params['id'])
    else
      redirect :action => :index
    end
  end

  def check_installed_apps
    @AppGalleries = GalleryApp.find(:all)      
    @AppGalleries.reject! { |app| app.select_build_link.nil? }
    
    @AppGalleries.each do |app|
      build = app.select_build_link
      if build && build.bundle_id && build.bundle_id != ""
        if System::app_installed? build.bundle_id
          app.downloading = "false"
          app.save
          app.state_install= "true"
        else
          #if error occurred during download toggle install
          if app.downloading == "true" and app.downloading and (Time.now.to_i > app.download_time.to_i)
            app.downloading = "false"
            app.download_time = ""
            app.save
            WebView.execute_js("load_page('/app/GalleryApp/index');")
          end
          app.state_install= "false"
        end
      end
    end
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
        redirect :action => :index, :query=>{:id => Gallery.curr_gallery}
      else
        redirect :action => :show,:query=>{:id=>@params['id'],:msg=>"Application is being installed",:btn_install_clicked=>'true'}
      end

      #download app in s3 for correct platform
      if platform == "APPLE"
        url = "itms-services://?action=download-manifest&url=#{url}"
        System.open_url(url)
      else
        puts "downloading s3 url: #{url}"
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
    #platform = System::get_property('platform')
    gallery_app = GalleryApp.find(@params['id'])
    if @params["status"] == "ok"
      System.applicationInstall(@params['file'])
      gallery_app.state_install = true
    else
      Alert.show_popup "Download Failed"
    end
    gallery_app.download_time = ""
    gallery_app.downloading = "false"
    gallery_app.save
    WebView.execute_js("load_page('/app/GalleryApp/index');");
  end

  
  def uninstall_app
    @gallery_app = GalleryApp.find(@params['id'])
    @gallery_app.state_install="false"
    
    System::applicationUninstall(@params['bundle_id']) if System::app_installed?(@params['bundle_id'])
    url = "/app/GalleryApp/show?id=#{@params['id']}&uninstall=true"
    WebView.execute_js("load_page('#{url}');");
  end

  def run_app
    begin
      token = "rhogallery_app"
      token = @params['security_token'] if @params['security_token'] && @params['security_token'] != ''
      System.runApplication(@params['bundle_id'],"security_token="+token) if @params['bundle_id']
    rescue Exception=>e
      Alert.show_popup "Application failed to open. Check bundle ID is correct."
      puts "error running app #{e.message}"
    end  
    redirect :action => :index, :query => {:id => Gallery.curr_gallery}
  end
end
