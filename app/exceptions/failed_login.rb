class FailedLogin < StandardError
  def initialize(message = nil)
    @message = message
  end

  def message
    @message
  end

  def code
    401
  end

  def sub_code
    :failed_login
  end
end
