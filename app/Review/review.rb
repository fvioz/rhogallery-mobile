# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Review
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Build.
  enable :sync
  set :sync_priority, 100
  #add model specific code here
  class << self
    attr_accessor :current_review
  end
end
