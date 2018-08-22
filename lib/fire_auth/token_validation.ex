defmodule FireAuth.TokenValidation do
  @moduledoc """
  Validation of firebase id_tokens.
  """
  require FireAuth.Util
  alias FireAuth.Util

  @doc """
  Validates a give token_string.
  This checks if the string was signed properly and is still valid.

  If this is true
  {:ok, 
    %{name: name, id: id, email: email, email_verified: email_verified, provider_id: provider_id}}
  is returned.

  In case there are any problems a error in the form
  {:error, error_message}
  is returned.
  """
  def validate_token(token_string) do
    with {:ok, token, header} <- parse(token_string),
         {:ok, claims} <- verify_token(token, header) do
      if check_token_claims(claims) do
        {:ok, claims}
      else
        {:error,
         "Token claims are invalid. (The token might be expired or the project_id might be wrong)"}
      end
    end
  end

  defp parse(token_string) do
    try do
      token = Joken.token(token_string)
      header = Joken.peek_header(token)
      {:ok, token, header}
    rescue
      error -> {:error, error}
    end
  end

  # checks that all requirements are met for the token claims
  defp check_token_claims(claims) do
    check_token_claims_exp(claims) && check_token_claims_iat(claims) &&
      check_token_claims_auth_time(claims) && check_token_claims_aud(claims) &&
      check_token_claims_iss(claims)
  end

  defp check_token_claims_exp(claims), do: Util.current_time() <= claims["exp"]
  defp check_token_claims_iat(claims), do: Util.current_time() >= claims["iat"]
  defp check_token_claims_auth_time(claims), do: Util.current_time() >= claims["auth_time"]
  defp check_token_claims_aud(claims), do: project_id() == claims["aud"]

  defp check_token_claims_iss(claims),
    do: "https://securetoken.google.com/#{project_id()}" == claims["iss"]

  # verifies a token using the keybase fetched from firebase.
  # returns
  #   {:ok, claims} when the token was verified successfully
  #   {:error, error_message} otherwise
  defp verify_token(token, %{"alg" => "RS256", "kid" => kid}) do
    cert = Map.get(FireAuth.KeyServer.get_keybase(), kid)

    case cert do
      nil ->
        {:error, "Could not find public certificate matching token kid."}

      cert ->
        jwk =
          cert
          # decode the cert read from googles json
          |> decode_cert()
          # use records to get the part we need
          |> Util.otp_certificate(:tbsCertificate)
          |> Util.otptbs_certificate(:subjectPublicKeyInfo)
          |> Util.otp_subject_public_key_info(:subjectPublicKey)
          # create our JWK token form it
          |> JOSE.JWK.from_key()

        # Validate the token
        # This returns the token with possible verify errors
        verified_token =
          token
          |> Joken.with_signer(Joken.rs256(jwk))
          |> Joken.verify()

        case verified_token do
          %{error: nil, claims: claims} ->
            {:ok, claims}

          %{error: error} ->
            {:error, "Token verification failed. #{inspect(error)}"}

          _ ->
            {:error, "Token verification failed. Unknown result."}
        end
    end
  end

  defp verify_token(_, _) do
    {:error, "Wrong algorithm in token header."}
  end

  # decodes the certificate with the kid given in the token id
  defp decode_cert(cert) do
    [{:Certificate, cert_entry, :not_encrypted}] = :public_key.pem_decode(cert)
    :public_key.pkix_decode_cert(cert_entry, :otp)
  end

  defp project_id() do
    Application.get_env(:fire_auth, :project_id) ||
      raise ":fire_auth, :project_id not set! Please add it to your config file."
  end
end
