gallery = Gallery.find(:first)
unless gallery
  @organization = Organization.create({:name=>'TestOrg',:username=>"TestUser"})
  @gallery = Gallery.create({:name=>'TestGallery',:owner_id=>@organization.object})
  4.times do |i|
    ga = GalleryApp.create({:name=>"App#{i}",:gallery_id=>@gallery.object,:owner_id=>@organization.object})
    Build.create({:file_urls=>"testurl_#{i}",:app_id=>ga.object,:build_type=>"ios"})
    3.times do |j|
      Review.create({:app_id=>ga.object,:title=>"Title#{j}",:stars=>j+1,:description=>"Create #{j} app"})
    end
  end

end