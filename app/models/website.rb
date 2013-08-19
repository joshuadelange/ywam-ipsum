class Website < ActiveRecord::Base
  attr_accessible :url

  has_many :page
end
