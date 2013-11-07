# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Account
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Account.
  enable :sync
  enable :full_update
  set :sync_priority, 6
  #add model specific code here
end
