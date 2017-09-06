class Searching
  ENHANCED_FIELDS = %w(
    document_collections
    specialist_sectors
    policies
    taxons
    mainstream_browse_pages
  ).freeze
  HEAD_FIELDS = %w(
    popularity
    is_historic
  ).freeze
  SECONDARY_HEAD_FIELDS = %w(
    people
    organisations
  ).freeze
  OTHER_FIELDS = %w(
    description
    format
    link
    public_timestamp
    title
    content_id
  ).freeze

  FIELDS = OTHER_FIELDS + ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS
  OPTION_FIELDS = ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS + %w(content_id)

  require 'gds_api/rummager'
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def count
    return 10 if params["count"].blank?
    return 1000 if params["count"].to_i > 1000
    params["count"]
  end

  def call
    rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
    findings_new_left = rummager.search(
      q: params["search_term"],
      fields: FIELDS,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:A",
      c: Time.now.getutc.to_s
      )
    findings_new_right = rummager.search(
      q: params["search_term"],
      fields: FIELDS,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:B",
      c: Time.now.getutc.to_s
      )
    Results.new(findings_new_left, findings_new_right)
  end
end
