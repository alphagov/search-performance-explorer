module DisplayFormatHelper
  DATE_HASH = {
    "01" => "January",
    "02" => "February",
    "03" => "March",
    "04" => "April",
    "05" => "May",
    "06" => "June",
    "07" => "July",
    "08" => "August",
    "09" => "September",
    "10" => "October",
    "11" => "November",
    "12" => "December"
  }.freeze

  def date_format(date)
    DATE_HASH[date[5..6]] + " #{date[0..3]}" if date != nil
  end

  def display_content_id(id)
    "Content ID: #{id}"
  end

  def display_format(doc)
    doc.split("_").join(" ").capitalize
  end

  def display_popularity(pop)
    "Popularity: #{pop}"
  end

  def historical_or_current(is_historical)
    return nil if is_historical == nil
    return "Current" if is_historical == false
    return "Historical" if is_historical == true
  end

  def link_format(link)
    if link.start_with?("https://", "http://")
      link
    elsif link.start_with?("www.")
      "https://#{link}"
    else
      "https://gov.uk" + link
    end
  end

  def name(link)
    if link_format(link).start_with?("http:")
      link_format(link)[14..-1].split("-").join(" ").split("/").join(" / ")
    else
      link_format(link)[15..-1].split("-").join(" ").split("/").join(" / ")
    end
  end
end
