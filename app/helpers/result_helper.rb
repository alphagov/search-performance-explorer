module ResultHelper
  def enabled?(thing)
    params['info'] == "enhanced" && params[thing] == "on"
  end
end
