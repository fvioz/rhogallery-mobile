require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ReviewController < Rho::RhoController
  include BrowserHelper

  def new
    @id        = @params['id']
    client_id  = Settings.find(:first).uuid
    @review = Review.find(:first,:conditions=>{'app_id'=>@id,'client_id'=>client_id})
    if @review
      Review.current_review = Review.find(:all).first
      render :action=>:edit
    else
      render
    end
  end

  def create
    @params.merge!({"client_id"=> Settings.find(:first).uuid,"sort_date"=>Time.now.to_i})
    Review.create(@params)
    render
  end

  def update
    @params.merge!({"sort_date"=>Time.now.to_i})
    Review.current_review.update_attributes(@params)
    render
  end
end