# frozen_string_literal: true

# Google OAuth2 OmniAuth strategy with PKCE (RFC 7636) support.
#
# omniauth-google-oauth2 1.0.1 overrides #build_access_token and does not merge
# the PKCE `code_verifier` into the token exchange. Google now enforces PKCE
# server-side, so the authorization code is rejected with `invalid_grant` /
# "Bad Request" at the callback. This subclass adds PKCE so the `code_challenge`
# is sent in the authorization request and the `code_verifier` is sent when
# exchanging the code for an access token.
class OmniAuth::Strategies::GoogleOauth2WithPkce < OmniAuth::Strategies::GoogleOauth2
  option :pkce, true

  # Merge the PKCE `code_verifier` (stored in the session during the
  # authorization request) into the token request params so Google accepts the
  # authorization code that was issued alongside a `code_challenge`.
  def get_token_params
    super.merge(pkce_token_params)
  end
end
