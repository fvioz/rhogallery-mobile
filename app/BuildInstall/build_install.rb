# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class BuildInstall
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with BuildInstall.
  enable :sync
  set :sync_priority, 101
  #add model specific code here

  def build
    Build.find(:all,:conditions=>{"object"=>self.build_id}).first
  end
end
