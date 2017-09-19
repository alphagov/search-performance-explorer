class Results
  attr_reader :left_total, :left_missing, :right_total, :right_missing, :left, :right, :result_count
  def initialize(left, right)
    @result_count = right['results'].count > left['results'].count ? right['results'].count : left['results'].count
    @left = (0..result_count - 1).map { |i| Result.new(left['results'][i]) }
    @right = (0..result_count - 1).map { |i| Result.new(right['results'][i]) }

    @left_total = left['total'] || left['result_count']
    @right_total = right['total'] || right['result_count']

    @left_missing = @left_total - left['results'].count
    @right_missing = @right_total - right['results'].count
  end

  def rows
    left.zip(right)
  end

  def search_left_list_for_link(link)
    left.index { |result| result["link"] == link }
  end

  def score_difference(link, position)
    search_left_list_for_link(link).present? ? (search_left_list_for_link(link) - position) : nil
  end
end
