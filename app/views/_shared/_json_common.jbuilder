if @prettify_json
  json.prettify!
end
if @pagy
  title = "#{@page_title} (page #{@pagy.page} of #{@pagy.last})"
else
  title = @page_title
end
json.prettify!
json.meta do
  json.title title
  json.license 'https://creativecommons.org/publicdomain/zero/1.0/'
  json.creator 'antleaf.com'
end