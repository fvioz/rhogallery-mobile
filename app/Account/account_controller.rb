require 'rho/rhocontroller'
require 'helpers/browser_helper'

class AccountController < Rho::RhoController
  include BrowserHelper

  # GET /Account
  def index
    @account = Account.find(:all).first
    @groups=@account.tags.split(',') if @account and @account.tags
    render
  end

  def edit
    @account = Account.find(@params['id'])
    @click_form = false;
    render :action => :edit
  end 
  
  def password_notification
    status = @params['status'] ? @params['status'] : ""
    if status == "error"
      errCode = @params['error_code'].to_i
      @msg = @params['error_message']
      elssg = Rho::RhoError.new(errCode).message
      WebView.navigate(url_for(:controller=>:Settings,:action => :login, :query => {:msg => @msg}))
    end

    if status == "ok"
      if SyncEngine::logged_in > 0
        WebView.navigate(url_for(:controller=>:Account,:action => :index))
      end
    end
  end


  def change_password
    # fix for "double click" issue in jqtouch
    if AppApplication.lastcall and (Time.now.to_i - AppApplication.lastcall) <= 1
      return redirect :controller=>:Settings,:action=>:password
    end
    AppApplication.lastcall = Time.now.to_i
    
    if @params['password'] != "" and @params['confirm_password'] != ""
      if @params['old_password'] != ""
        if @params['password']==@params['confirm_password']
          settings = Settings.find(:first)
          if settings
            body = "old_password=#{@params['old_password']}&"
            body += "login=#{settings.account_id}&"
            body += "username=#{settings.username}&"
            body += "password=#{@params['password']}"
            url = "#{Rho::RhoConfig.rhogallery_webservice.strip.gsub(/'/,"")}change_password"
            Rho::AsyncHttp.post(
              :url => url,
              :body => body,
              :callback => (url_for :action => :httppost_callback),
              :callback_param => "" )
            
            redirect :controller=>:Settings,:action => :wait
          else
            redirect :controller=>:Settings,:action=>:logout
            Alert.show_popup(
              :message => "Unexpected error, please login again.\n",
              :title=>"",
              :buttons => ["Ok"]
            )
          end
        else
          redirect :controller=>:Account,:action=>:password
          Alert.show_popup(
            :message => "The password and the confirmation password don't match.\n",
            :title=>"",
            :buttons => ["Ok"]
          )
        end
      else
        redirect :controller=>:Account,:action=>:password
        Alert.show_popup(
          :message=>"The password can't be empty, please try again.\n",
          :title=>"",
          :buttons => ["Ok"]
        )
      end
    else
      redirect :controller=>:Account,:action=>:password
      Alert.show_popup(
        :message=>"The new password can't be empty.\n",
        :title=>"",
        :buttons => ["Ok"]
      )
    end
  end

  def httppost_callback
    if @params['body'] && @params['body'] != 'Bad credential'
      if @params['status'] == 'ok'
        @@error_params = @params
        WebView.navigate ( url_for :controller=>:Settings,:action => :index )
        Alert.show_popup :message => "Password changed successfully.",:title=>"",:buttons => ['Ok']
      end
    else
      WebView.navigate ( url_for :controller=>:Settings,:action => :password )
      Alert.show_popup :message=>"The old password is incorrect, please try again.",:title=>"",:buttons => ["Ok"]
    end
  end

  
  def update
    @account = Account.find(:all).first
    if @account
      @account.update_attributes(@params['account']) 
      SyncEngine.dosync_source(@account.source_id,false)
    end
    redirect :action => :index
  end
 
  def password
    @account = Account.find(:all).first
    if System::get_property('platform') == 'Blackberry'
      @menu = {"Close" => :close}
    end
    render :action => :password  
  end
end
