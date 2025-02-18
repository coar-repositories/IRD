# frozen_string_literal: true

class AnnotateJob < ApplicationJob
  queue_as :default

  def perform(system_id, annotation, add_or_remove)
    system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
    if add_or_remove == :add
      system.add_annotation annotation
    elsif add_or_remove == :remove
      system.remove_annotation annotation
    end
    system.save! # this is needed, as add_annotation and remove_annotation do not update the index
  end
end
