require 'rho/rhocontroller'
require 'helpers/browser_helper'

class GalleryController < Rho::RhoController
  include BrowserHelper

  # GET /Gallery
  def index
    puts "inside gallery index"
    if SyncEngine::logged_in > 0
      Organization.curr_org = Organization.find(:first) unless Organization.curr_org
      @galleries = Gallery.find(:all,:conditions=>{"owner_id" => Organization.curr_org.object})
      if @galleries && @galleries.length == 1
        redirect :controller => :GalleryApp, :action => :index, :query => {:id => @galleries[0].object}
      else
        render :action=>:index, :back => "/app/Organization"
      end
    else
      redirect :controller=>:Settings,:action => :login, :query=>{:msg=>nil}
    end
  end

  def do_sync
    Settings.sync = true
    WebView.execute_js("show_sync();");
    Rho::RhoConnectClient.doSync
    WebView.navigate(url_for(:action => :index))
  end

  #GET /Gallery/{1}
  # def show
  #   @gallery = Gallery.find(@params['id'])
  #   if @gallery
  #     @galleryapps = @gallery.gallery_apps
  #     render :action => :show, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # GET /Gallery/new
  # def new
  #   @gallery = Gallery.new
  #   render :action => :new, :back => url_for(:action => :index)
  # end

  # # GET /Gallery/{1}/edit
  # def edit
  #   @gallery = Gallery.find(@params['id'])
  #   if @gallery
  #     render :action => :edit, :back => url_for(:action => :index)
  #   else
  #     redirect :action => :index
  #   end
  # end

  # # POST /Gallery/create
  # def create
  #   @gallery = Gallery.create(@params['gallery'])
  #   redirect :action => :index
  # end

  # # POST /Gallery/{1}/update
  # def update
  #   @gallery = Gallery.find(@params['id'])
  #   @gallery.update_attributes(@params['gallery']) if @gallery
  #   redirect :action => :index
  # end

  # # POST /Gallery/{1}/delete
  # def delete
  #   @gallery = Gallery.find(@params['id'])
  #   @gallery.destroy if @gallery
  #   redirect :action => :index  
  # end
end
