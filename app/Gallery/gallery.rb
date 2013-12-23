# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Gallery
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Gallery.
  enable :sync
  set :sync_priority, 10
  #add model specific code here
  class << self
    attr_accessor :curr_gallery
  end

  def gallery_apps
    ga = GalleryApp.find(:all,:conditions =>{:gallery_id =>self.object})
    ga.reject{ |app| app.select_build_link.nil? }
  end
end
