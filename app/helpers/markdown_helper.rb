# frozen_string_literal: true
module MarkdownHelper
  require 'kramdown'

  def process_md(md)
    Kramdown::Document.new(md).to_html.html_safe
  end

end
