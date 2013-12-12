require 'rho/rhocontroller'
require 'helpers/browser_helper'

class BuildController < Rho::RhoController
  include BrowserHelper

  # GET /Build
  # def index
  #   @builds = Build.find(:all)
  #   render :back => '/app'
  # end

  # # GET /Build/{1}
  # def show
  #   @build = Build.find(@params['id'])
  #   if @build
  #     render :action => :show, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # GET /Build/new
  # def new
  #   @build = Build.new
  #   render :action => :new, :back => url_for(:action => :index)
  # end

  # # GET /Build/{1}/edit
  # def edit
  #   @build = Build.find(@params['id'])
  #   if @build
  #     render :action => :edit, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # POST /Build/create
  # def create
  #   @build = Build.create(@params['build'])
  #   redirect :action => :index
  # end

  # # POST /Build/{1}/update
  # def update
  #   @build = Build.find(@params['id'])
  #   @build.update_attributes(@params['build']) if @build
  #   redirect :action => :index
  # end

  # # POST /Build/{1}/delete
  # def delete
  #   @build = Build.find(@params['id'])
  #   @build.destroy if @build
  #   redirect :action => :index  
  # end
end
