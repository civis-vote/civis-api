class BaseException < StandardError
  def initialize(message = nil)
    @message = message
  end

  def message
    @message
  end

  def code
    500
  end

  def sub_code
    :internal_server_error
  end
end
