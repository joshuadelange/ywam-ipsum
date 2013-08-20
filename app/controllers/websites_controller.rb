class WebsitesController < ApplicationController

  # POST /websites
  def create

    unless params[:url].empty?

      Website.create(
        :url => params[:url],
        :approved => false
      ).save

      redirect_to root_path

    end

  end

end