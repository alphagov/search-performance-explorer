module ResultHelper
  def enabled?(thing)
    params['info'] == "enhanced" && params[thing] == "on"
  end

  def compare(left, right)
    return 'up' if right == Searching::Results::NOT_FOUND
    change = right - left
    return 'up' if change.positive?
    change.negative? ? 'down' : 'changeless'
  end
end
