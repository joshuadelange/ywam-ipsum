class WelcomeController < ApplicationController
  def index

    @websites = Website.all()

    @top_words = Word.find(
      :all,
      :select => "word, count(*) as count",
      :group => "word",
      :order => "count desc",
      :limit => 20
    )

  end
end
