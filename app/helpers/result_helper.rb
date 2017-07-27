module ResultHelper

  things_to_check = %w(
    content_id document_collections historical mainstream_browse_pages
    organisations people policies popularity taxons specialist_sectors
  )

  things_to_check.each do |thing|
    define_method("#{thing}_enabled?") do
      return false if params['info'] == "basic" || params[thing] != "on"
      true
    end
  end
end
