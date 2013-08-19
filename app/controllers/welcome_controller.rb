class WelcomeController < ApplicationController
  def index
    @websites = Website.all()
  end
end
