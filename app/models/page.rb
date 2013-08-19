class Page < ActiveRecord::Base
  attr_accessible :url, :needs_crawling, :website_id

  belongs_to :website
end
