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
      description
      format
      link
      public_timestamp
      title
      content_id
      document_collections
      is_historic
      mainstream_browse_pages
      organisations
      people
      policies
      popularity
      specialist_sectors
      taxons
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
      @left = (0..result_count - 1).map { |i| Result.new(left['results'][i]) }
      @right = (0..result_count - 1).map { |i| Result.new(right['results'][i]) }
      @left_total = left['total']
      @right_total = right['total']
      @left_missing = @left_total - left['results'].count
      @right_missing = @right_total - right['results'].count
    end

    def rows
      left.zip(right)
    end

    def search_left_list_for_link(link)
      r = left.find { |result| result.info["link"].include?(link) }
      left.index(r) if r
    end

    def score_difference(link, position)
      return (search_left_list_for_link(link) - position).to_s if search_left_list_for_link(link)
      "++++"
    end
  end

  class Result
    require 'uri'
    attr_reader :info
    def initialize(info)
      @info = info
    end

    def date_format(date)
      DateTime.parse(date).strftime("%B %Y") unless date.nil?
    end

    def get_enhanced_results(enhanced_fields)
      enhanced_results_hash = {}
      enhanced_fields.each do |field|
        return_array = []
        @info[field].each do |t|
          if field == 'taxons' || field == 'policies'
            return_array << [make_readable(t), '']
          elsif field == "mainstream_browse_pages"
            return_array << [make_readable(t), "https://gov.uk/browse/#{t}"]
          else
            return_array << [t['title'], "https://gov.uk/#{t['link']}"]
          end
          enhanced_results_hash[field.titleize] = return_array.uniq
        end
      end
      return enhanced_results_hash
    end

    def get_head_info_list(fields)
      head_info_list = [@info['format'].humanize, date_format(@info['public_timestamp'])]
      head_info_list << historical_or_current(info['is_historic']) if fields.include?("historical")
      head_info_list << "Popularity: #{info['popularity']}" if fields.include?("popularity")
      head_info_list
    end

    def historical_or_current(check)
      return "Historical" if check == true
      return "Current" if check == false
    end

    def make_readable(text)
      text.gsub("/", " / ").tr("-", " ")
    end

    def name
      make_readable(URI(@info["link"]).path)
    end
  end
end
