describe "Gallery" do
  #this test always fails, you really should have tests!

  it "should have one gallery" do
    Gallery.find(:all).count.should == 1
  end

  it "should have galleryapp association" do 
    gallery = Gallery.find(:first)
    gallery.gallery_apps.count.should == 4
  end
end