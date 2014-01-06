describe "Organization" do
  #this test always fails, you really should have tests!

  it "should have one org" do
    Organization.find(:all).count.should == 1
  end

  it "should have gallery association" do 
    org = Organization.find(:first)
    org.galleries.count.should == 1
  end
end