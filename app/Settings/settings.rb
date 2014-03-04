#The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Settings
  include Rhom::PropertyBag
  @@settings = false
  class << self
    attr_accessor :sync,:current_url
  end

  def self.process_ok(source_name)
    case source_name
    when "Version"
      platform = System::get_property('platform').downcase
      v        = Version.find(platform)
      org      = Organization.find_owner
      if v.version != Rho::RhoConfig.version
        SyncEngine.stop_sync
        System.open_url(org.short_url)
      end
    # when "CustomBuild"
    #   platform = System::get_property('platform').downcase
    #   cb = CustomBuild.find(platform)
    #   if cb.version != Rho::RhoConfig.version
    #     SyncEngine.stop_sync
    #     System.open_url(cb.short_url)
    #   end
    #build is last synced resource, hide sync indicators after
    when "Organization"
      WebView.navigate("/app/Organization") if Settings.current_url == "Organization"
    when "GalleryApp"
      WebView.navigate("/app/GalleryApp") if Settings.current_url == "GalleryApp"
    when "Gallery"
      WebView.navigate("/app/Gallery") if Settings.current_url == "Gallery"
      WebView.navigate("/app/Organization") if Settings.current_url == "Organization"
    when "BuildInstall"
      Settings.sync = false
      WebView.execute_js("hide_sync();")
    end
  end

  def self.process_error(params)
    Settings.sync = false
    WebView.execute_js("hide_sync();")
    if params['server_errors'] && params['server_errors']['create-error']
      Rho::RhoConnectClient.on_sync_create_error(
        params['source_name'], params['server_errors']['create-error'].keys, :recreate )
    end

    if params['server_errors'] && params['server_errors']['update-error']
      Rho::RhoConnectClient.on_sync_update_error(
        params['source_name'], params['server_errors']['update-error'], :retry )
    end
    
    err_code = params['error_code'].to_i
    rho_error = Rho::RhoError.new(err_code)
    @msg = params['error_message'] if err_code == Rho::RhoError::ERR_CUSTOMSYNCSERVER
    @msg = rho_error.message unless @msg && @msg.length > 0   

    if rho_error.unknown_client?( params['error_message'] )
      Rhom::Rhom.database_client_reset
      Rho::RhoConnectClient.doSync
    elsif err_code == Rho::RhoError::ERR_UNATHORIZED
      msg = "Server credentials are expired"
      Rho::WebView.navigate("/app/Settings/login?msg=#{msg}")             
    elsif err_code != Rho::RhoError::ERR_CUSTOMSYNCSERVER
      Rho::WebView.navigate("/app/Settings/login?msg=#{@msg}")
    end    
  end
end