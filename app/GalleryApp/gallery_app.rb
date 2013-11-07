# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class GalleryApp
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with GalleryApp.
  enable :sync
  set :sync_priority, 20
  #add model specific code here
  attr_accessor :build, :build_install

  def reviews
    #Review.find(:all,:conditions =>{:galleryapp_id =>self.object})
    Review.find(:all)
  end

  def review_avg_hsh
    #Review.find(:all,:conditions =>{:galleryapp_id =>self.object})
    reviews = Review.find(:all)
    hsh = {"5"=>0,"4"=>0,"3"=>0,"2"=>0,"1"=>0,"0"=>0}
    reviews.each do |review|
      hsh[review.stars] += 1
    end
    hsh
  end

  def review_avg
    #Review.find(:all,:conditions =>{:galleryapp_id =>self.object})
    reviews = Review.find(:all)
    total = 0
    reviews.each do |review|
      total += review.stars.to_i
    end
    puts "total is #{total}"
    puts "reviews.count is #{reviews.count}"
    (total / reviews.count).floor
  end
  
  def select_build_link
    platforms = {
      'APPLE' => 'iOS', 
      'WINDOWS' => 'Windows Mobile', 
      'ANDROID' => 'Android',
      'WINDOWS_DESKTOP' => 'Win32'
    }
    platform = platforms[System.get_property('platform')]
    begin
      # filter build list by platform
      conditions = {
        :app_id => object,
        :device => platform
      }
      build = Build.find(:all, 
        :conditions => conditions,
        :order => :version
      )
      @build = (build and build.size > 0) ? build.last : nil
    rescue Exception=>e
      puts "exception **************** #{e.message}"
      @build = nil
    end
    @build
  end
  
  def state_install=(state)
    build = select_build_link
    
    install = BuildInstall.find(:first,
      :conditions => {
        :build_id => build.object
      }
    )
  
    unless install
      install = BuildInstall.new({:locked=>'true'})
      install.build_id = build.object
    end
    
    if state == "false"
      install.destroy
    else
      install.executable_id = build.executable_id 
      install.installed = state
      install.save
      self.build_install = install
    end
  end
  
  def state_install
    installed = "false"
  
    build = select_build_link
    install = BuildInstall.find(:first,
      :conditions => {
        :build_id => build.object
      }
    )
    if build && build.executable_id && build.executable_id != ""
      if System::app_installed? build.executable_id
        installed = "true"
      elsif build.url == 'vpp' and install and install.locked == 'true'
        installed = "maybe"
      end
    end
    
    if installed == "false"
      installed = install ? install.installed : "false"
    end
    installed
  end
end
