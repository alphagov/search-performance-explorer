class Searching
  ENHANCED_FIELDS = %w[
    document_collections
    specialist_sectors
    policies
    taxons
    mainstream_browse_pages
  ].freeze
  HEAD_FIELDS = %w[
    popularity
    is_historic
  ].freeze
  SECONDARY_HEAD_FIELDS = %w[
    people
    organisations
  ].freeze
  OTHER_FIELDS = %w[
    description
    format
    link
    public_timestamp
    title
    content_id
  ].freeze

  FIELDS = OTHER_FIELDS + ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS
  OPTION_FIELDS = ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS + %w[content_id].freeze

  HOSTS = {
    "production" => "https://www.gov.uk/api",
    "integration" => "https://www-origin.integration.publishing.service.gov.uk/api",
    "staging" => "https://www-origin.staging.publishing.service.gov.uk/api",
    "development" => "http://rummager.dev.gov.uk",
  }.freeze

  AB_TESTS = {
    "shingles" => { a: "shingles:A", b: "shingles:B" },
    "none" => { a: "", b: "" },
    "learning_to_rank" => { a: "relevance:disable", b: "" },
    "shingles_without_ltr" => { a: "shingles:A,relevance:disable", b: "shingles:B,relevance:disable" },
    "hippo" => { a: "", b: "mv:hippo" },
    "elephant" => { a: "", b: "mv:elephant" },
  }.freeze

  require "gds_api/search"
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def count
    count = params["search"]["count"].to_i
    return 10 if count.zero? || count.negative?
    return 1000 if count > 1000

    count
  end

  def call
    ab_tests = AB_TESTS[params["search"]["which_test"]] || AB_TESTS["none"]
    findings_new_left = search_data(params["search"]["host_a"], ab_tests[:a])
    findings_new_right = search_data(params["search"]["host_b"], ab_tests[:b])
    Results.new(findings_new_left, findings_new_right)
  end

  def search_data(host_name, test)
    search_client = GdsApi::Search.new(HOSTS[host_name])
    search_client.search(
      {
        q: params["search"]["search_term"],
        fields: FIELDS,
        count: count.to_s,
        ab_tests: test,
        c: Time.zone.now.getutc.to_s,
      },
      "Authorization" => ENV["#{host_name.upcase}_AUTH_TOKEN"],
    )
  end
end
