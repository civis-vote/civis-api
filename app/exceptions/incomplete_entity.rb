class IncompleteEntity < StandardError
  def initialize(message = nil)
    @message = message
  end

  def message
    @message
  end

  def code
    422
  end

  def sub_code
    :incomplete_entity
  end
end
