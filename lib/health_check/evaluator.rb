module HealthCheck
  class Evaluator
    MIN_EXAMINATIONS = 10

    attr_reader :attractiveness, :satisfyingness

    def initialize(model)
      @attractiveness = JSON.parse(model["attr"])
      @satisfyingness = JSON.parse(model["sat"])
    end

    def score(query, content_ids, at_rank: 5)
      current = discounted_cumulative_gain(query, content_ids.take(at_rank))
      best = discounted_cumulative_gain(query, best_ordering(query).take(at_rank))

      current / best
    end

    def relevance(query, content_id)
      a = attractiveness[query][content_id]
      s = satisfyingness[query][content_id]

      if a.nil? || s.nil? || a["_denominator"] < MIN_EXAMINATIONS
        0
      else
        (a["_numerator"] * s["_numerator"]).to_f / (a["_denominator"] * s["_denominator"])
      end
    end

    def queries
      attractiveness.keys
    end

    def best_ordering(query)
      possible_results = attractiveness[query].keys
      possible_results.sort_by { |content_id| -relevance(query, content_id) }
    end

    def discounted_cumulative_gain(query, content_ids)
      score = 0
      content_ids.each_with_index do |content_id, i|
        r = relevance(query, content_id)

        score += r / Math.log2(i + 2)
      end

      score
    end
  end
end
