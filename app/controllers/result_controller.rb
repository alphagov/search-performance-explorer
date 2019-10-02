class ResultController < ApplicationController
  def index
    @head_fields = Searching::HEAD_FIELDS.select { |field| enabled?(field) }
    @secondary_head_fields = Searching::SECONDARY_HEAD_FIELDS.select { |field| enabled?(field) }
    @enhanced_results_fields = Searching::ENHANCED_FIELDS.select { |field| enabled?(field) }
    @show_content_id = enabled?("content_id")

    defaults = { host_a: "production", host_b: "production" }
    @search = SearchForm.new(defaults.merge(search_params))
    @results = Searching.new(params).call
  end

private

  def enabled?(thing)
    params["info"] == "enhanced" && params[thing] == "on"
  end

  def search_params
    return {} unless params[:search]

    params.require(:search).permit(*SearchForm::PARAMS)
  end
end

class SearchForm
  include ActiveModel::Model
  PARAMS = %i(
    content_id
    count
    document_collections
    host_a
    host_b
    info
    is_historic
    mainstream_browse_pages
    organisations
    people
    policies
    popularity
    search_term
    specialist_sectors
    taxons
    which_test
  ).freeze
  attr_accessor(*PARAMS)

  def search_term?
    search_term.present?
  end
end
