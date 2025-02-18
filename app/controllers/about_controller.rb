class AboutController < ApplicationController
  def index
    # authorize :about
    @page_title = t('page_titles.about')
  end
end
