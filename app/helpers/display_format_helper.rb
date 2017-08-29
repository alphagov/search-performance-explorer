module DisplayFormatHelper
  def link_format(link)
    if link == nil || link.start_with?("https://", "http://")
      link
    elsif link.start_with?("www.")
      "https://#{link}"
    else
      "https://gov.uk" + link
    end
  end
end
