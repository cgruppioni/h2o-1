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

    url = URI('http://127.0.0.1:3000/')
    response = Net::HTTP.post_form(url, 'q' => 'case data')

    render plain: response
    # render plain: 'Thanks for sending a GET request with cURL!'
  end
end
