# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Build
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Build.
  enable :sync
  set :sync_priority, 100
  #add model specific code here

  def url 
    self.file_urls
  end
end
