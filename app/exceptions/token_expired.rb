class TokenExpired < BaseException
  def message
    'Token expired, Login again to continue'
  end

  def code
    401
  end

  def sub_code
    :unauthorized
  end
end
