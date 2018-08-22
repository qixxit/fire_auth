defmodule FireAuth do
  @moduledoc """
  Used to authenticate users with firebase id tokens.
  Usage:

  plug FireAuth
  ...
  plug FireAuth.Secure, group: "required_group"
  """
  import Plug.Conn
  require Logger

  def init(_opts) do
  end

  def call(conn, _opts) do
    auth_token =
      conn
      |> Plug.Conn.get_req_header("authorization")
      |> Enum.map(&String.split/1)
      |> Enum.filter(fn e -> length(e) == 2 end)
      |> Enum.filter(fn [type, _] -> String.downcase(type) == "bearer" end)
      |> Enum.map(fn [_, token] -> token end)
      |> Enum.at(0)

    if auth_token do
      case validate_token(auth_token) do
        {:ok, info} ->
          fire_auth = %{
            authenticated: true,
            token_info: info
          }

          assign(conn, :fire_auth, fire_auth)

        _ ->
          fire_auth = %{
            authenticated: false,
            token_info: nil
          }

          assign(conn, :fire_auth, fire_auth)
      end
    else
      fire_auth = %{
        authenticated: false,
        token_info: nil
      }

      assign(conn, :fire_auth, fire_auth)
    end
  end

  @doc """
  Validates a firebase id token.
  Returns the informatinon encoded in the token.
  """
  def validate_token(token) do
    FireAuth.TokenValidation.validate_token(token)
  end
end
