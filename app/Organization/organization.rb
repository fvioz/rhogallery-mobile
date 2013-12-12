# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
require "digest/md5"
class Organization
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Organization.
  enable :sync
  set :sync_priority, 1
  #add model specific code here
  class << self
    attr_accessor :curr_org
  end
  
  def galleries
    Gallery.find(:all,:conditions =>{:owner_id =>self.object})
  end
end
