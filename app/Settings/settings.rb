#The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Settings
  include Rhom::PropertyBag
  @@settings = false
  class << self
    attr_accessor :sync
  end

  def self.process_ok(source_name)
    case source_name
    when "Version"
      version = Version.find(:first)
      if version.version != Rho::RhoConfig.version
        SyncEngine.stop_sync
        WebView.navigate( url_for :action => :badversion )
      end
    #build is last synced resource, hide sync indicators after
    when "BuildInstall"
      Settings.sync = false
      WebView.execute_js("hide_sync();");
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