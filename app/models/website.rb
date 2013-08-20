class Website < ActiveRecord::Base
  attr_accessible :url, :approved

  has_many :page
end
