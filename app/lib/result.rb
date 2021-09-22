class Result
  require "uri"
  delegate :[], to: :@info
  def initialize(info)
    @info = info
  end

  def enhanced_results(enhanced_fields)
    return_hash = {}
    enhanced_fields.each do |field|
      next if @info[field].blank?

      return_hash[field.titleize] = @info[field].map { |t| link_title_pair(t, field) }
    end
    return_hash
  end

  def get_head_info_list(fields)
    head_info_list = [@info["format"].humanize, date_format(@info["public_timestamp"])]
    head_info_list << historical_or_current(@info["is_historic"]) if fields.include?("is_historic")
    head_info_list << "Popularity: #{@info['popularity']}" if fields.include?("popularity")
    head_info_list
  end

  def link
    format_link(@info["link"])
  end

  def name
    make_readable(@info["link"]).strip
  end

  def second_head(fields)
    (fields.include?("people") ? people : []) + (fields.include?("organisations") ? organisations : [])
  end

private

  def date_format(date)
    Time.zone.parse(date).strftime("%B %Y") unless date.nil?
  end

  def format_link(link, extra = "")
    return link if link.nil? || link.start_with?("https://", "http://")
    return "https://#{link}" if link.start_with?("www.")

    "https://gov.uk#{extra}#{link}"
  end

  def historical_or_current(check)
    return if check.nil?

    check ? "Historical" : "Current"
  end

  def link_title_pair(link, field)
    return [make_readable(link), ""] if field == "taxons"
    return [make_readable(link), format_link(link, "/government/policies/")] if field == "policies"
    return [make_readable(link), format_link(link, "/browse/")] if field == "mainstream_browse_pages"

    [link["title"], format_link(link["link"])]
  end

  def make_readable(text)
    text.gsub("/", " / ").tr("-", " ")
  end

  def organisations
    return [] if @info["organisations"].blank?

    @info["organisations"].map do |details|
      [details["title"], format_link(details["link"])]
    end
  end

  def people
    return [] if @info["people"].blank?

    @info["people"].map do |details|
      [details["title"], format_link(details["link"])]
    end
  end
end
