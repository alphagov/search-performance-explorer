module ResultHelper
  def compare(left, right)
    return 'up' if right == Results::NOT_FOUND
    change = right - left
    return 'up' if change.positive?
    change.negative? ? 'down' : 'changeless'
  end
end
