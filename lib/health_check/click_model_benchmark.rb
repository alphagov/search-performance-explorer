require "gds_api/rummager"
require "health_check/evaluator"
require "rainbow"

module HealthCheck
  class ClickModelBenchmark
    def self.load_model
      file = File.read(DATA_DIR + "/click_model.json")
      JSON.parse(file)
    end

    def initialize(search_client:, model: ClickModelBenchmark.load_model)
      @rummager = search_client
      @model = model
    end

    def run!
      evaluator = HealthCheck::Evaluator.new(model)

      scores = []
      evaluator.queries.each do |query|
        search_results = rummager.search(
          query,
          fields: "content_id,title",
          count: 20,
        )

        search_ordering = search_results[:results].map { |result| result["content_id"] }

        query_score = evaluator.score(query, search_ordering)
        report_query(query, query_score)

        scores << query_score
      end

      # This weights all the queries evenly - ideally it would weight query scores according
      # to usage.
      ave = scores.sum.fdiv(scores.size) * 100
      report_average_score(ave)
    end

  private

    attr_reader :rummager
    attr_reader :model

    def report_query(query, query_score)
      title = Rainbow(query).yellow + ": "
      puts title.ljust(40) + query_score.round(2).to_s
    end

    def report_average_score(ave)
      puts Rainbow("-" * 35).cyan
      puts Rainbow("TOTAL SCORE:").cyan.ljust(39) + Rainbow("#{ave.round(1)}%").cyan
      puts Rainbow("-" * 35).cyan
    end
  end
end
