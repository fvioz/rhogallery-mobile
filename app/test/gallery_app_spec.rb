require "app/test/spec_helper"

describe "GalleryApp" do
  #this test always fails, you really should have tests!

  it "should return correct amount of reviews" do
    apps = GalleryApp.find(:all)
    apps.count.should == 4
  end

  it "should return build for app" do 
    app = GalleryApp.find(:first)
    build = app.select_build_link
    build.url.should =~ /testurl/
  end

  it "should return reviews for app" do 
    app = GalleryApp.find(:first)
    app.reviews.count.should == 3
  end

  it "should return avg review for all reviews" do 
    app = GalleryApp.find(:first)
    app.review_avg.should == 2
  end

  it "should return avg review for all reviews" do 
    app = GalleryApp.find(:first)
    app.review_avg_hsh["3"].should == 1
  end

  
end