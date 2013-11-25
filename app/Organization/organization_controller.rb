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
      #remember to change to :login from do_login after testing period
      redirect :controller=>:Settings,:action => :do_login,:query=>{:msg=>nil}
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

  # GET /Organization/new
  # def new
  #   @organization = Organization.new
  #   render :action => :new, :back => url_for(:action => :index)
  # end

  # # GET /Organization/{1}/edit
  # def edit
  #   @organization = Organization.find(@params['id'])
  #   if @organization
  #     render :action => :edit, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # POST /Organization/create
  # def create
  #   @organization = Organization.create(@params['organization'])
  #   redirect :action => :index
  # end

  # # POST /Organization/{1}/update
  # def update
  #   @organization = Organization.find(@params['id'])
  #   @organization.update_attributes(@params['organization']) if @organization
  #   redirect :action => :index
  # end

  # # POST /Organization/{1}/delete
  # def delete
  #   @organization = Organization.find(@params['id'])
  #   @organization.destroy if @organization
  #   redirect :action => :index  
  # end
end
