require 'rho/rhocontroller'
require 'helpers/browser_helper'

class GalleryController < Rho::RhoController
  include BrowserHelper

  # GET /Gallery
  def index
    org = Organization.curr_org || Organization.find(:all).first
    @galleries = Gallery.find(:all,:conditions=>{"owner_id" => org.object})
  end

  def do_sync
    Settings.sync = true
    WebView.execute_js("show_sync();")
    Rho::RhoConnectClient.doSync
    puts "Settings.current_url is *********************** #{Settings.current_url}"
    WebView.navigate("/app/#{Settings.current_url}")
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
