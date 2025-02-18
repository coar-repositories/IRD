# frozen_string_literal: true

module Curation
  extend ActiveSupport::Concern
  Issue = Struct.new(:priority, :description)
end
