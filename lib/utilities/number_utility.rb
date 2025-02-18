# frozen_string_literal: true

module Utilities
  class NumberUtility
    def self.get_percentage(n, total,rounding_places=0)
      if total > 0
        (n.to_f / total.to_f * 100.0).round(rounding_places)
      else
        0
      end
    end
  end
end
