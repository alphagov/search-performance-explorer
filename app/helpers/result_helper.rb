module ResultHelper
  def compare(left, right)
    return 'found' if right == nil
    change = right - left
    return 'up' if change.positive?
    change.negative? ? 'down' : 'changeless'
  end
end
