class Searching
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
    fields = %w(
      title link public_timestamp description format
      )
    findings_new_left = rummager.search(
      q: params["search_term"],
      fields: fields,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:A",
      c: Time.now.getutc.to_s
      )
    findings_new_right = rummager.search(
      q: params["search_term"],
      fields: fields,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:B",
      c: Time.now.getutc.to_s
      )
    Results.new(findings_new_left, findings_new_right)
  end

  class Results
    attr_reader :left_total, :left_missing, :right_total, :right_missing, :left, :right, :result_count
    def initialize(left, right)
      @result_count = right['results'].count > left['results'].count ? right['results'].count : left['results'].count
      @left = (0..result_count - 1).map { |i| left['results'][i] }
      @right = (0..result_count - 1).map { |i| right['results'][i] }
      @left_total = left['total']
      @right_total = right['total']
      @left_missing = @left_total - left['results'].count
      @right_missing = @right_total - right['results'].count
    end

    def rows
      left.zip(right)
    end

    def search_left_list_for_link(link)
      r = left.find { |result| result["link"].include?(link) }
      left.index(r) if r
    end

    def score_difference(link, position)
      return (search_left_list_for_link(link) - position).to_s if search_left_list_for_link(link)
      "++++"
    end
  end
end
