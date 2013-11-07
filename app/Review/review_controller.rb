require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ReviewController < Rho::RhoController
  include BrowserHelper

  def new
    @id        = @params['id']
    client_id = System.getProperty("uuid")
    puts "uuid is ************ #{client_id}"
    @review = Review.find(:first,:conditions=>{'client_id'=>client_id})
    if @review
      Review.current_review = Review.find(:all).first
      Review.current_review = Review.create({:client_id=>'testid',:stars=>2,:description=>"very good app",:title=>"great"}) unless Review.current_review
      render :action=>:edit
    else
      render
    end
  end

  def create
    @params.merge!({"client_id"=> System.getProperty("uuid")})
    Review.create(@params)
    render
  end

  def update
    Review.current_review.update_attributes(@params)
    render
  end
end