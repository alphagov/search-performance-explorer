module DisplayFormatHelper
  require 'uri'
  def date_format(date)
    DateTime.parse(date).strftime("%B %Y") unless date.nil?
  end

  def head_info_list_maker(info)
    head_info_list = [info['format'].humanize, date_format(info['public_timestamp'])]
    head_info_list << historical_or_current(info['is_historic']) if enabled?("historical")
    head_info_list
  end

  def historical_or_current(check)
    return "Historical" if check == true
    return "Current" if check == false
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
    URI(link).path.tr('-', ' ').gsub('/', ' / ')
  end
end
