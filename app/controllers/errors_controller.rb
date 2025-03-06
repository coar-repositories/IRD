class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html do
        @page_title = t("http_codes.404")
        render(:status => 404)
      end
      format.json do
        render(:json => { :error => t("http_codes.404"), status: 404 }, :status => 404)
      end
      format.csv do
        render plain: t("http_codes.404")
      end
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html do
        @page_title = t("http_codes.500")
        render(:status => 500)
      end
      format.json do
        render(:json => { :error => t("http_codes.500"), status: 500 }, :status => 500)
      end
      format.csv do
        render plain: t("http_codes.500")
      end
    end
  end

  def forbidden
    respond_to do |format|
      format.html do
        @page_title = t("http_codes.403")
        render(:status => 403)
      end
      format.json do
        render(:json => { :error => t("http_codes.403"), status: 403 }, :status => 403)
      end
      format.csv do
        render plain: t("http_codes.403")
      end
    end
  end
end
