class ResultController < ApplicationController
  def index
    @head_fields = Searching::HEAD_FIELDS.select { |field| enabled?(field) }
    @secondary_head_fields = Searching::SECONDARY_HEAD_FIELDS.select { |field| enabled?(field) }
    @enhanced_results_fields = Searching::ENHANCED_FIELDS.select { |field| enabled?(field) }
    @show_content_id = enabled?("content_id")
  end

private

  def enabled?(thing)
    params['info'] == "enhanced" && params[thing] == "on"
  end
end
