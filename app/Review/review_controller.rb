require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ReviewController < Rho::RhoController
  include BrowserHelper

  def new
    @id        = @params['id']
    client_id  = Rho::System.phoneId
    @review = Review.find(:first,:conditions=>{'app_id'=>@id,'client_id'=>client_id})
    if @review
      Review.current_review = Review.find(:all).first
      render :action=>:edit
    else
      render
    end
  end

  def create
    @params.merge!({"client_id"=> Rho::System.phoneId})
    Review.create(@params)
    render
  end

  def update
    Review.current_review.update_attributes(@params)
    render
  end
end