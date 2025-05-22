class Unauthorized < StandardError
  def initialize(message = nil)
    @message = message
  end

  def message
    @message || 'User is not authorized to perform this action'
  end

  def code
    401
  end

  def sub_code
    :unauthorized
  end
end
