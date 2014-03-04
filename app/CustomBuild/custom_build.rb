# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class CustomBuild
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Version.
  enable :sync
  set :sync_priority, 2
  #add model specific code here
end
