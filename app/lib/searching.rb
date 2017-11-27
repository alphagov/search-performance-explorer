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
  OPTION_FIELDS = ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS + %w(content_id).freeze

  HOSTS = {
    "production" => "https://www.gov.uk/api",
    "integration" => "https://www-origin.integration.publishing.service.gov.uk/api",
    "staging" => "https://www-origin.staging.publishing.service.gov.uk/api",
    "development" => "http://rummager.dev.gov.uk"
  }.freeze

  require 'gds_api/rummager'
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
    findings_new_left = rummager_data(params["search"]["host_a"], 'A')
    findings_new_right = rummager_data(params["search"]["host_b"], 'B')
    Results.new(findings_new_left, findings_new_right)
  end

  def rummager_data(host_name, test)
    url = "https://www-origin.staging.publishing.service.gov.uk/api/search.json?q=#{params['search']['search_term']}&fields=#{FIELDS.join(',')}&count=#{count.to_s}&ab_tests=#{params['search']['which_test']}:#{test}&c=#{Time.now.getutc.to_s}"
    response = RestClient::Request.execute(:method => :get, :url => url)
    JSON.parse(response.body)
  end
end
