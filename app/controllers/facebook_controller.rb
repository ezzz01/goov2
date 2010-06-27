class FacebookController < ApplicationController

  def index
    respond_to do |format|
      format.fbml
  end
  end
end
