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
    terms = @params["search_term"].split.join("+")
    rummager = GdsApi::Rummager.new(Plek.new.find('rummager'))
    findings_new_left = rummager.search(q:      "#{terms}",
                                        fields: [ "is_historic", "title", "link", "popularity", "public_timestamp", "description",
                                                  "format", "content_id", "document_collections", "mainstream_browse_pages",
                                                  "organisations", "taxons", "people", "policies", "specialist_sectors"],
                                        count:  "#{count}", ab_tests: "#{params["which_test"]}:A", c: "#{Time.now.getutc}")
    findings_new_right = rummager.search(q:      "#{terms}",
                                        fields: [ "is_historic", "title", "link", "popularity", "public_timestamp", "description",
                                                  "format", "content_id", "document_collections", "mainstream_browse_pages",
                                                  "organisations", "taxons", "people", "policies", "specialist_sectors"],
                                        count:  "#{count}", ab_tests: "#{params["which_test"]}:B", c: "#{Time.now.getutc}")
    Results.new(findings_new_left, findings_new_right)
  end

  class Results
    attr_reader :results, :left_total, :left_missing, :right_total, :right_missing
    def initialize(left, right)
      result_count = right['results'].count > left['results'].count ? right['results'].count : left['results'].count
      @results = (0..result_count-1).map { |i| Result.new(left, right, i) }
      @left_total = left['total']
      @right_total = right['total']
      @left_missing = @left_total - left['results'].count
      @right_missing = @right_total - right['results'].count
    end
  end

  class Result
    attr_reader :left, :right, :position, :enhanced_results_hash
    def initialize(left, right, position)
      @left = left['results'].each_with_index.map {|r, i| [r, i]}
      @right = right['results'].each_with_index.map {|r, i| [r, i]}
      @position = position
      @date_hash = {
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
              "12" => "December" }
      @enhanced_results_hash = {}
    end

    def content_id(side)
      begin
        side[position][0]['content_id']
      rescue
        nil
      else
        side[position][0]['content_id']
      end
    end
    def date(side)
      begin
        side[position][0]['public_timestamp'][0..9]
      rescue
        nil
      else
        @date_hash["#{side[position][0]['public_timestamp'][5..6]}"] + " #{side[position][0]['public_timestamp'][0..3]}"
      end
    end
    def description(side)
      begin
        side[position][0]['description']
      rescue
        nil
      else
        side[position][0]['description']
      end
    end
    def document_collections(side)
      begin
        side[position][0]['document_collections']
      rescue
        nil
      else
        if side[position][0]['document_collections'] != nil
          return_array = []
          side[position][0]['document_collections'].each do |sector|
            return_array << [sector['title'], "https://www.gov.uk"+sector['link']]
          end
          @enhanced_results_hash["Document Collections"] = return_array.uniq
        end
      end
    end
    def doc_format(side)
      side[position] && side[position][0]['format']
    end
    def historical(side)
      begin
        side[position][0]['is_historic']
      rescue
        nil
      else
        return nil if side[position][0]['is_historic'] == nil
        side[position][0]['is_historic'] == true ? "Historical" : "Current"
      end
    end
    def link(side)
      begin
        side[position][0]['link']
      rescue
        nil
      else
        if side[position][0]['link'].start_with?("https://") || side[position][0]['link'].start_with?("http://")
          side[position][0]['link']
        elsif side[position][0]['link'].start_with?("www.")
          "https://#{side[position][0]['link']}"
        else
          "https://gov.uk" + side[position][0]['link']
        end
      end
    end
    def mainstream_browse_pages(side)
      begin
        side[position][0]['mainstream_browse_pages']
      rescue
        nil
      else
        if side[position][0]['mainstream_browse_pages'] != nil
          return_array = []
          side[position][0]['mainstream_browse_pages'].each do |page|
            return_array << [ page.split("/").join(" / ").split("-").join(" "), "https://gov.uk/browse/" + page ]
          end
          @enhanced_results_hash["Mainstream Browse Pages"] = return_array.uniq
        end
      end
    end
    def name(side)
      if link(side).include?("www.")
        link(side)[19..-1].split("-").join(" ").split("/").join(" / ")
      else
        link(side)[15..-1].split("-").join(" ").split("/").join(" / ")
      end
    end
    def organisations(side)
      begin
        side[position][0]['organisations']
      rescue
        nil
      else
        return_array = []
        if side[position][0]['organisations'] != nil
          side[position][0]['organisations'].each do |organisation|
            return_array << [organisation['title'], "https://gov.uk#{organisation['link']}"]
          end
          return_array
        end
      end
    end
    def people(side)
      begin
        side[position][0]['people'][0]['title']
      rescue
        nil
      else
        return_array = []
        if side[position][0]['people'] != nil
          side[position][0]['people'].each do |person|
            return_array << [person['title'], "https://gov.uk#{person['link']}"]
          end
          return_array
        end
      end
    end
    def policies(side)
      begin
        side[position][0]['policies']
      rescue
        nil
      else
        if side[position][0]['policies'] != nil
          return_array = []
          side[position][0]['policies'].each do |policy|
            return_array << [policy.split("-").join(" "), ""]
          end
          @enhanced_results_hash["Policies"] = return_array.uniq
        end
      end
    end
    def popularity(side)
      begin
        side[position][0]['popularity']
      rescue
        nil
      else
        side[position][0]['popularity']
      end
    end
    def taxons(side)
      begin
        side[position][0]['taxons']
      rescue
        nil
      else
        if side[position][0]['taxons'] != nil
          return_array = []
          side[position][0]['taxons'].each do |taxon|
            return_array << [taxon, ""]
          end
          @enhanced_results_hash["Taxons"] = return_array.uniq
        end
      end
    end
    def title(side)
      begin
        side[position][0]['title']
      rescue
        nil
      else
        side[position][0]['title']
      end
    end
    def specialist_sectors(side)
      begin
        side[position][0]['specialist_sectors']
      rescue
        nil
      else
        if side[position][0]['specialist_sectors'] != nil
          return_array = []
          side[position][0]['specialist_sectors'].each do |sector|
            return_array << [sector['title'], "https://gov.uk"+sector['link']]
          end
          @enhanced_results_hash["Specialist Sectors"] = return_array.uniq
        end
      end
    end

    def right_position_in_left_list
      r = left.detect { |l| l[0]['link'] == link(right) || l[0]['link'] == link(right)[14..-1]}
      r[1] if r
    end

    def score_difference
      if right_position_in_left_list
        score_difference = right_position_in_left_list - position
      else
        score_difference = "++++"
      end
    end

  end

end
