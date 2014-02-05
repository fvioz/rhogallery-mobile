require 'rho/rhocontroller'
require 'helpers/browser_helper'

class OrganizationController < Rho::RhoController
  include BrowserHelper

  # GET /Organization
  def index
    if SyncEngine::logged_in > 0
      @organizations = Organization.find(:all)
      render :back => '/app'
    else
      redirect :controller=>:Settings,:action => :login,:query=>{:msg=>nil}
    end
  end

  # GET /Organization/{1}
  def show
    @organization = Organization.find(@params['id'])
    if @organization
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  #set organization
  def set_org
    organization = Organization.find(@params['id'])
    Organization.curr_org = organization
    redirect :controller=>"Gallery",:action=>'index'
  end

end
