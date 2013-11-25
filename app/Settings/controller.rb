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

  def login_callback
    puts "params are #{@params.inspect}"
    errCode = @params['error_code'].to_i
    if errCode == 0
      # run sync if we were successful
      Rho::WebView.navigate Rho::Application.settingsPageURI
      Rho::RhoConnectClient.doSync
    else
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      end
        
      if !@msg || @msg.length == 0   
        @msg = Rho::RhoError.new(errCode).message
      end
      
      Rho::WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    end  
  end

  def do_login
    #@params['account']='msitechops'
    #@params['login']= 'guest'
    #@params['password']= 'cccfjwyy'

    #@params['account']='lucas'
    @params['email']= 'lucas.campbellrossen@gmail.com'
    @params['password']= 'SfVGaGz5'

    if @params['email'] and @params['password'] #and @params['account']
      begin
        #username_params = "#{@params['login']}_rho_#{@params['account']}"
        #password_params = "#{@params['password']}_rho_#{Rho.get_app.gallery_platform(System.get_property('platform')).downcase}"
        settings = Settings.find(:all)
        if settings and settings.size > 0
          #settings[0].account_id = @params['email']
          settings[0].email = @params['email']
          settings[0].save
        else
          Settings.create(
            #:account_id => @params['email'],
            :username => @params['email']
          )
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
  # def do_login_old
  #   #@params['account']='msitechops'
  #   #@params['login']= 'guest'
  #   #@params['password']= 'cccfjwyy'

  #   @params['account']='lucas'
  #   @params['login']= 'tom'
  #   @params['password']= 'fhnrxihd'

  #   if @params['login'] and @params['password'] and @params['account']
  #     begin
  #       username_params = "#{@params['login']}_rho_#{@params['account']}"
  #       password_params = "#{@params['password']}_rho_#{Rho.get_app.gallery_platform(System.get_property('platform')).downcase}"
  #       settings = Settings.find(:all)
  #       if settings and settings.size > 0
  #         settings[0].account_id = @params['login']
  #         settings[0].username = @params['account']
  #         settings[0].save
  #       else
  #         Settings.create(
  #           :account_id => @params['login'],
  #           :username => @params['account']
  #         )
  #       end
  #       Rho::RhoConnectClient.login(username_params,password_params, (url_for :action => :login_callback) )
  #       @response['headers']['Wait-Page'] = 'true'
  #       render :action => :wait
  #     rescue Rho::RhoError => e
  #       @msg = e.message
  #       puts "error: #{e.message}"
  #       render :action => :login
  #     end
  #   else
  #     puts "no login found error"
  #     @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
  #     render :action => :login
  #   end
  # end
  
  def logout
    Rhom::Rhom.database_full_reset
    Rho::RhoConnectClient.logout
    @msg = "You have been logged out."
    render :action => :login
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
    Rho::RhoConnectClient.doSync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    Rho::RhoConnectClient.doSync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def sync_notify
    platform = System::get_property('platform')
    status = @params['status'] ? @params['status'] : ""
    
    # un-comment to show a debug status pop-up
    #Rho::Notification.showStatus( "Status", "#{@params['source_name']} : #{status}", Rho::RhoMessages.get_message('hide'))
    if status == "ok"
      Settings.process_ok(@params['source_name'])
    elsif status == "in_progress"   
      # do nothing
    elsif status == "complete"
      Alert.hide_popup
      gallery_apps = GalleryApp.find(:all)
      installed_apps = BuildInstall.find(:all)
      
      installed_apps.delete_if do |app|
        delete = false
        gallery_apps.each do |gapp|
          delete = true if gapp.object == app.app_id
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
        if System::app_installed?(app.executable_id)
          System::app_uninstall(app.executable_id)
        end
      end
    end
  end  

  
end
