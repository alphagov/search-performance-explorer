class ResultController < ApplicationController
  def index
    @head_fields = Searching::HEAD_FIELDS.select { |field| view_context.enabled?(field) }
    @secondary_head_fields = Searching::SECONDARY_HEAD_FIELDS.select { |field| view_context.enabled?(field) }
    @enhanced_results_fields = Searching::ENHANCED_FIELDS.select { |field| view_context.enabled?(field) }
  end
end
