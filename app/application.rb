require 'rho/rhoapplication'
require 'helpers/application_helper'

class AppApplication < Rho::RhoApplication
  include ApplicationHelper
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    @@toolbar = nil
    super
    @default_menu = {}
    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # Rho::RhoConnectClient.setObjectNotification("/app/Settings/sync_notify")
    Rho::RhoConnectClient.setNotification('*', "/app/Settings/sync_notify", '')
  end
end
