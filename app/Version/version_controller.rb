require 'rho/rhocontroller'
require 'helpers/browser_helper'

class VersionController < Rho::RhoController
  include BrowserHelper

  # GET /Version
  def index
    @versions = Version.find(:all)
    render :back => '/app'
  end

  # GET /Version/{1}
  def show
    @version = Version.find(@params['id'])
    if @version
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Version/new
  def new
    @version = Version.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Version/{1}/edit
  def edit
    @version = Version.find(@params['id'])
    if @version
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Version/create
  def create
    @version = Version.create(@params['version'])
    redirect :action => :index
  end

  # POST /Version/{1}/update
  def update
    @version = Version.find(@params['id'])
    @version.update_attributes(@params['version']) if @version
    redirect :action => :index
  end

  # POST /Version/{1}/delete
  def delete
    @version = Version.find(@params['id'])
    @version.destroy if @version
    redirect :action => :index  
  end
end
