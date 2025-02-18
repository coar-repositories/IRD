module AdminHelper
  require 'cgi'

  def unescape(s)
    CGI.unescapeURIComponent(s)
  end
end
