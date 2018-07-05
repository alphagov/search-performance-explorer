require "gds_api/rummager"

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
        scores << query_score

        puts "#{query}: #{query_score.round(2)}"
      end

      ave = scores.sum.fdiv(scores.size) * 100
      puts "\nTOTAL SCORE: #{ave.round(1)}%"
    end

  private

    attr_reader :rummager
    attr_reader :model
  end
end
