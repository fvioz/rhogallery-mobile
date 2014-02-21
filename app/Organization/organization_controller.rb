require 'rho/rhocontroller'
require 'helpers/browser_helper'

class OrganizationController < Rho::RhoController
  include BrowserHelper

  # GET /Organization
  def index
    if SyncEngine::logged_in > 0
      #remove user account if no gallereis
      @organizations = Organization.find(:all).delete_if{|org|org.galleries.size < 1}
    else
      if Rho::RhoConfig.email.size > 0
        redirect :controller=>:Settings,:action => :do_login,:query=>{:email=>Rho::RhoConfig.email,:password=>Rho::RhoConfig.password} 
      else
        redirect :controller=>:Settings,:action => :login, :query=>{:msg=>nil}
      end
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
