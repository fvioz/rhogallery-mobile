require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
 
  def index
    @msg = @params['msg']
    render
  end
    
  def login
    @msg = @params['msg']
    render :action => :login
  end

  def set_current_url
    puts "current url set to #{@params['id']}"
    Settings.current_url = @params['id']
  end

  def login_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
      # run sync if we were successful
      Settings.current_url = "Organization"
      WebView.navigate("/app/Organization")
      WebView.execute_js("show_sync();")
      Settings.sync = true
      Rho::RhoConnectClient.doSync
    else
      puts "error message is #{@params['error_message']}"
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      end
        
      if !@msg || @msg.length == 0
        @msg = Rho::RhoError.new(errCode).message
      end
      
      @msg << " Please ensure the device has the correct date and timezone."
      WebView.navigate( url_for :action => :login, :query => {:msg => @msg} )
    end  
  end

  def do_login
    if @params['email'] and @params['password']
      begin
        settings = Settings.find(:all)
        if settings and settings.size > 0
          settings[0].email = @params['email']
          settings[0].save
        else
         settings = Settings.create({
            :username => @params['email'],
            :uuid     => (0...8).map { (65 + rand(26)).chr }.join
          })
        end
        Rho::RhoConnectClient.login(@params['email'],@params['password'], (url_for :action => :login_callback) )
        @response['headers']['Wait-Page'] = 'true'
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        puts "error: #{e.message}"
        render :action => :login
      end
    else
      puts "no login found error"
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :login
    end
  end
  
  def logout
    Rhom::Rhom.database_full_reset
    Rho::RhoConnectClient.logout
    Settings.sync = false
    WebView.execute_js("hide_sync();");
    @msg = "You have been logged out."
    render :action => :login
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Settings.sync = true
    Rhom::Rhom.database_full_reset
    Rho::RhoConnectClient.doSync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    Settings.sync = true
    WebView.execute_js("show_sync();");
    Rho::RhoConnectClient.doSync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def sync_notify
    platform = System::get_property('platform')
    status = @params['status'] ? @params['status'] : ""
    
    # un-comment to show a debug status pop-up
    if status == "ok"
      Settings.process_ok(@params['source_name'])
    elsif status == "complete"
      gallery_apps = GalleryApp.find(:all)
      installed_apps = BuildInstall.find(:all)
      
      installed_apps.delete_if do |app|
        delete = false
        gallery_apps.each do |gapp|
          delete = true if gapp.object == app.build.app_id
        end
        delete
      end
      #Rho::WebView.navigate Rho::RhoConfig.start_path if @params['sync_type'] != 'bulk'
    elsif status == "error"
      Settings.process_error(@params)
    end
    #only installed apps left are ones that arent in galleries -- uninstall them
    unless installed_apps.nil?
      installed_apps.each do |app|
        if System::app_installed?(app.bundle_id)
          System::app_uninstall(app.bundle_id)
        end
      end
    end
  end  

  
end
