class HelpController < ApplicationController
  def index
    # authorize :help
    # @page_title = t(:about, scope: :page_titles)
    @page_title = t('page_titles.help')
  end
end
