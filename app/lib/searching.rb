class Searching
  require 'gds_api/rummager'
  attr_reader :params, :params_checker
  def initialize(params)
    @params = params
  end

  def count
    return 10 if params["count"].blank?
    return 1000 if params["count"].to_i > 1000
    params["count"]
  end

  def call
    terms = params["search_term"].split.join("+")
    rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
    fields = %w(
      is_historic title link popularity public_timestamp description
      format content_id document_collections mainstream_browse_pages
      organisations taxons people policies specialist_sectors
      )
    findings_new_left = rummager.search(q: terms, fields: fields, count: count.to_s,
      ab_tests: "#{params['which_test']}:A", c: Time.now.getutc.to_s)
    findings_new_right = rummager.search(q: terms, fields: fields, count: count.to_s,
      ab_tests: "#{params['which_test']}:B", c: Time.now.getutc.to_s)
    Results.new(findings_new_left, findings_new_right)
  end

  class Results
    attr_reader :results, :left_total, :left_missing, :right_total, :right_missing
    def initialize(left, right)
      result_count = right['results'].count > left['results'].count ? right['results'].count : left['results'].count
      @results = (0..result_count - 1).map { |i| Result.new(left, right, i) }
      @left_total = left['total']
      @right_total = right['total']
      @left_missing = @left_total - left['results'].count
      @right_missing = @right_total - right['results'].count
    end
  end

  class Result
    attr_reader :left, :right, :position, :enhanced_results_hash, :display
    def initialize(left, right, position)
      @left = left['results'].each_with_index.map { |r, i| [r, i] }
      @right = right['results'].each_with_index.map { |r, i| [r, i] }
      @position = position
      @enhanced_results_hash = {}
    end

    simple_methods = %w(content_id date description doc_format historical link popularity title)

    simple_methods.each do |method|
      define_method "#{method}" do |side|
      if side[position]
        method = "format" if method == "doc_format"
        side[position][0][method]
      end
      end
    end

#    def content_id(side) # => simple
#      if side[position]
#        side[position][0]['content_id']
#      end
#    end
#
#    def date(side) # => simple
#      if side[position]
#        side[position][0]['public_timestamp']
#      end
#    end
#
#    def description(side) # => simple
#      if side[position]
#        side[position][0]['description']
#      end
#    end

    def document_collections(side)# => enhanced_results_hash
      if side[position]
        if side[position][0]['document_collections'] != nil
          return_array = []
          side[position][0]['document_collections'].each do |sector|
            return_array << [sector['title'], "https://www.gov.uk" + sector['link']]
          end
          @enhanced_results_hash["Document Collections"] = return_array.uniq
        end
      end
    end

#    def doc_format(side) # => simple
#      if side[position]
#        side[position][0]['format']
#      end
#    end
#
#    def historical(side) # => simple
 #     if side[position]
 #       side[position][0]['is_historic']
 #     end
 #   end

 #   def link(side) # => simple
 #     if side[position]
 #       side[position][0]['link']
 #     end
 #   end

    def mainstream_browse_pages(side)# => enhanced_results_hash
      if side[position]
        if side[position][0]['mainstream_browse_pages'] != nil
          return_array = []
          side[position][0]['mainstream_browse_pages'].each do |page|
            return_array << [page.split("/").join(" / ").split("-").join(" "), "https://gov.uk/browse/" + page]
          end
          @enhanced_results_hash["Mainstream Browse Pages"] = return_array.uniq
        end
      end
    end

    def organisations(side) # => array return
      if side[position]
        if side[position][0]['organisations'] != nil
          return_array = []
          side[position][0]['organisations'].each do |organisation|
            return_array << [organisation['title'], "https://gov.uk#{organisation['link']}"]
          end
          return_array
        end
      end
    end

    def people(side) # => array return
      if side[position]
        if side[position][0]['people'] != nil
          return_array = []
          side[position][0]['people'].each do |person|
            return_array << [person['title'], "https://gov.uk#{person['link']}"]
          end
          return_array
        end
      end
    end

    def policies(side) # => enhanced_results_hash
      if side[position]
        if side[position][0]['policies'] != nil
          return_array = []
          side[position][0]['policies'].each do |policy|
            return_array << [policy.split("-").join(" "), ""]
          end
          @enhanced_results_hash["Policies"] = return_array.uniq
        end
      end
    end

#    def popularity(side) # => simple
#      if side[position]
#        side[position][0]['popularity']
#      end
#    end

    def taxons(side) # => enhanced_results_hash
      if side[position]
        if side[position][0]['taxons'] != nil
          return_array = []
          side[position][0]['taxons'].each do |taxon|
            return_array << [taxon, ""]
          end
          @enhanced_results_hash["Taxons"] = return_array.uniq
        end
      end
    end

#    def title(side) # simple
#      if side[position]
#        side[position][0]['title']
#      end
#    end

    def specialist_sectors(side) # => enhanced_results_hash
      if side[position]
        if side[position][0]['specialist_sectors'] != nil
          return_array = []
          side[position][0]['specialist_sectors'].each do |sector|
            return_array << [sector['title'], "https://gov.uk" + sector['link'].to_s]
          end
          @enhanced_results_hash["Specialist Sectors"] = return_array.uniq
        end
      end
    end

    def right_position_in_left_list
      r = left.detect { |l| l[0]['link'] == link(right) || l[0]['link'] == link(right)[14..-1] }
      r[1] if r
    end

    def score_difference
      if right_position_in_left_list
        right_position_in_left_list - position
      else
        "++++"
      end
    end
  end
end
