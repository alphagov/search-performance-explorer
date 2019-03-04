module Explainotron
  def self.explain!(query, hostname: Plek.find('search'))
    client = GdsApi::Rummager.new(hostname)

    Results.new(
      query,
      client.search(
        q: query,
        debug: "explain,disable_best_bets,disable_popularity,disable_boosting",
        count: 3
      )["results"]
    )
  end

  class Results
    def initialize(query, results)
      @results = results
      @query = query
    end

    def report
      results.each do |result|
        title = result["title"]
        description = result["description"]
        puts Rainbow(title).yellow + " - #{description}"
        puts ""
        report_result(result["_explanation"])
        puts ""
      end
    end

  private

    attr_reader :query, :results

    def report_result(explain_output, indent: 0)
      details = explain_output["details"]
      value = explain_output["value"]
      description = explain_output["description"]

      description.gsub!(/[0-9.]+/) do |match|
        Rainbow(match).cyan
      end

      description.gsub!(/(?<=:)(.*)(?= in)/) do |match|
        Rainbow(match).green
      end

      spaces = ' ' * indent
      puts spaces.to_s + Rainbow("[#{value}] ").magenta + description

      if details
        details.each do |detail|
          report_result(detail, indent: indent + 2)
        end
      end
    end
  end
end
