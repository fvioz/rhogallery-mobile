#The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Settings
  include Rhom::PropertyBag


  def self.process_ok(source_name)
    case source_name
    when "Version"
      version = Version.find(:first)
      if version.version != Rho::RhoConfig.version
        SyncEngine.stop_sync
        WebView.navigate( url_for :action => :badversion )
      end
    when "Account"
      account = Account.find(:first)
      if account.active && account.active != "true"
        SyncEngine.stop_sync
        SyncEngine.logout
        WebView.navigate( url_for :action => :login )
        Alert.show_popup "Account not active. You have been logged out."
      end
    when "Gallery" 
      Alert.show_status( "Synchronizing", "Galleries", Rho::RhoMessages.get_message('hide'))
    when "BuildInstall" 
      Alert.show_status( "Synchronizing", "BuildInstalls", Rho::RhoMessages.get_message('hide'))
    when "GalleryApp"
      Alert.show_status( "Synchronizing", "Applications", Rho::RhoMessages.get_message('hide'))
    when "Build"
      Alert.show_status( "Synchronizing", "Builds", Rho::RhoMessages.get_message('hide'))
    end
  end

  def self.process_error(params)
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
      Rho::WebView.navigate(
        url_for :action => :login, 
        :query => {:msg => "Server credentials are expired"} )                
    elsif err_code != Rho::RhoError::ERR_CUSTOMSYNCSERVER
      Rho::WebView.navigate( url_for :action => :err_sync, :query => { :msg => @msg } )
    end    
  end
end