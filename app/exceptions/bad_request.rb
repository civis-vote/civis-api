class BadRequest < BaseException
  def code
    400
  end

  def sub_code
    :bad_request
  end
end
