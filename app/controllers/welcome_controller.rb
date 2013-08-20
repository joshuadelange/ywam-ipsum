class WelcomeController < ApplicationController
  def index

    @websites = Website.all()

    @top_words = Word.find(
      :all,
      :select => "word, count(*) as count",
      :group => "word",
      :order => "count desc",
      :limit => 100,
      :conditions => "word not IN ('ywam', 'a', 'an', 'the', 'and', 'for', 'of', 'to', 'in', 'is', 'with')"
    )

    @number_of_words = Word.count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")
    @number_of_pages = Page.count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")
    @number_of_websites = Website.count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ")

  end
end
