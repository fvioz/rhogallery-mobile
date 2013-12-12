require 'rho/rhocontroller'
require 'helpers/browser_helper'

class BuildInstallController < Rho::RhoController
  include BrowserHelper

  # GET /BuildInstall
  # def index
  #   @buildinstalls = BuildInstall.find(:all)
  #   render :back => '/app'
  # end

  # # GET /BuildInstall/{1}
  # def show
  #   @buildinstall = BuildInstall.find(@params['id'])
  #   if @buildinstall
  #     render :action => :show, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # GET /BuildInstall/new
  # def new
  #   @buildinstall = BuildInstall.new
  #   render :action => :new, :back => url_for(:action => :index)
  # end

  # # GET /BuildInstall/{1}/edit
  # def edit
  #   @buildinstall = BuildInstall.find(@params['id'])
  #   if @buildinstall
  #     render :action => :edit, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # POST /BuildInstall/create
  # def create
  #   @buildinstall = BuildInstall.create(@params['buildinstall'])
  #   redirect :action => :index
  # end

  # # POST /BuildInstall/{1}/update
  # def update
  #   @buildinstall = BuildInstall.find(@params['id'])
  #   @buildinstall.update_attributes(@params['buildinstall']) if @buildinstall
  #   redirect :action => :index
  # end

  # # POST /BuildInstall/{1}/delete
  # def delete
  #   @buildinstall = BuildInstall.find(@params['id'])
  #   @buildinstall.destroy if @buildinstall
  #   redirect :action => :index  
  # end
end
