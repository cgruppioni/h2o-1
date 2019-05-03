require 'faraday'

class BaseController < ApplicationController
  caches_page :index, :if => Proc.new { |c| c.instance_variable_get('@page_cache') }

  layout :layout_switch

  def landing
    if current_user
      @user = current_user
      @page_title = I18n.t 'content.titles.dashboard'
      render 'content/dashboard', layout: 'main'
    else
      render 'base/index', layout: 'main'
    end
  end

  # Layout is always false for ajax calls
  def layout_switch
    return false if request.xhr?
  end

  def curl_get_example
    kase = Case.last
    content = {content: kase.content, id: kase.id}

    conn = Faraday.new(:url => 'http://127.0.0.1:3000/') do |faraday|
      faraday.request  :url_encoded   # form-encode POST params
      faraday.response :logger   # log requests to $stdout
      faraday.adapter  Faraday.default_adapter 
    end

    response = conn.post '/', { :case => content}

    render plain: response.body
    # render plain: response.inspect
  end
end
