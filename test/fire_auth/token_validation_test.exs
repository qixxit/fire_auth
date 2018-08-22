defmodule FireAuth.TokenValidationTest do
  use ExUnit.Case

  alias FireAuth.TokenValidation

  @valid_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyNzE3N2FmNzhjYTk2Yjk0NjBjMDc0OGEwYzcyODM1MjA1M2YxMzYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbmFkYS1wcmV2aWV3IiwicHJvdmlkZXJfaWQiOiJhbm9ueW1vdXMiLCJhdWQiOiJuYWRhLXByZXZpZXciLCJhdXRoX3RpbWUiOjE1MDMzNDU1NDcsInVzZXJfaWQiOiI4bmluOEVQQVEzVE1nSHhIWEpldE10R2NIbGUyIiwic3ViIjoiOG5pbjhFUEFRM1RNZ0h4SFhKZXRNdEdjSGxlMiIsImlhdCI6MTUwMzM1MDQ4MywiZXhwIjoxNTAzMzU0MDgzLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7fSwic2lnbl9pbl9wcm92aWRlciI6ImFub255bW91cyJ9fQ.tlMfsd1CHXyHiAmbBcVGdEMUvQSvYY2bZeX8pWHGdN1pJ-PCisK8r28mBHI1-pHQTXgRH84MF92BmHYKPeJapEP13pnVgPZqqfXJ44i0-QGeCbVWHthzs_O-i1W4PAxjn0fUL_K9ZeU7vqbDUCIkgx3MtfOhn-ASfo2ead9vgZquSJP7DnV4KScOvJ8-yJDStQvfnSbYKTfCBQAp-rD95ZKhmQhpUUcFjy0ameephgHBvywyOkkNVJquteH33wh3X-2LaNoK6YF0xTmzJ234DMVZ_RNo3GtHZZ51hoJKXv8rZcHxxs3pv2XsgOQbuq5CEy78-XNBsso_wy4gQnYlbg"

  @expired_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyNzE3N2FmNzhjYTk2Yjk0NjBjMDc0OGEwYzcyODM1MjA1M2YxMzYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbmFkYS1wcmV2aWV3IiwicHJvdmlkZXJfaWQiOiJhbm9ueW1vdXMiLCJhdWQiOiJuYWRhLXByZXZpZXciLCJhdXRoX3RpbWUiOjE1MDMzNDU1NDcsInVzZXJfaWQiOiI4bmluOEVQQVEzVE1nSHhIWEpldE10R2NIbGUyIiwic3ViIjoiOG5pbjhFUEFRM1RNZ0h4SFhKZXRNdEdjSGxlMiIsImlhdCI6MTUwMzM0NTU0OCwiZXhwIjoxNTAzMzQ5MTQ4LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7fSwic2lnbl9pbl9wcm92aWRlciI6ImFub255bW91cyJ9fQ.WLdNP6VvXbgAaGyh0w-ZqgdtAXhfJpZ5OQ0aLu5E63opsmhPqdw2trZHcmpX35vHVAEQ1jIxNs_X8-WrSPdzPWYPpJCCGc0jY35DCj8JVlPsWCOlYvDL0uFSPsZYQIvy9wpwEfAC2eb5OH5bGIOQluwy8x2NO1PHjk2jbpEn7NXlp5tS-3JzI1oz-aaREGSwy-1U89rL8FnKz5dVZhxUySXjJeGMGq8MMvAyNCHU8FkflX5bT6eUiR2GGIrNbcvtErmWbLvd18o68qeCaw6myI9-97MCTvWJmdo_K4uH4XUH20AU50sskhqknTcheKj_w2qjAGHZ-cfIbWbKuseBjw"

  @invalid_token "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyNzE3N2FmNzhjYTk2Yjk0NjBjMDc0OGEwYzcyODM1MjA1M2YxMzYifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbmFkYS1wcmV2aWV3IiwicHJvdmlkZXJfaWQiOiJhbm9ueW1vdXMiLCJhdWQiOiJuYWRhLXByZXZpZXciLCJhdXRoX3RpbWUiOjE1MDMzNDU1NDcsInVzZXJfaWQiOiI4bmluOEVQQVEzVE1nSHhIWEpldE10R2NIbGUyIiwic3ViIjoiOG5pbjhFUEFRM1RNZ0h4SFhKZXRNdEdjSGxlMiIsImlhdCI6MTUwMzM0NTU0OCwiZXhwIjoxNTAzMzQ5MTQ4LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7fSwic2lnbl9pbl9wcm92aWRlciI6ImFub255bW91cyJ9fQ.WLdNP6VvXbgAaGyh0w-ZqgdtAXhfJpZ5OQ0aLu5E63opsmhPqdw2trZHcmpX35vHVAEQ1jIxNs_X8-WrSPdzPWYPpJCCGc0jY35DCj8JVlPsWCOlYvDL0uFSPsZYQIvy9wpwEfAC2eb5OH5bGIOQluwy8x2NO1PHjk2jbpEn7NXlp5tS-3JzI1oz-aaREGSwy-1U89rL8FnKz5dVZhxUySXjJeGMGq8MMvAyNCHU8FkflX5bT6eUiR2GGIrNbcvtErmWbLvd18o68qeCaw6myI9-97MCTvWJmdo_K4uH4XUH20AU50sskhqknTcheKj_w2qjAGHZ-cfIbWbKuseBjb"

  @tag :capture_log
  test "valid_token returns correct content" do
    expected_result = %{
      "aud" => "nada-preview",
      "auth_time" => 1_503_345_547,
      "exp" => 1_503_354_083,
      "firebase" => %{
        "identities" => %{},
        "sign_in_provider" => "anonymous"
      },
      "iat" => 1_503_350_483,
      "iss" => "https://securetoken.google.com/nada-preview",
      "provider_id" => "anonymous",
      "sub" => "8nin8EPAQ3TMgHxHXJetMtGcHle2",
      "user_id" => "8nin8EPAQ3TMgHxHXJetMtGcHle2"
    }

    assert {:ok, expected_result} == TokenValidation.validate_token(@valid_token)
  end

  @tag :capture_log
  test "expired_token returns error" do
    assert {:error,
            "Token claims are invalid. (The token might be expired or the project_id might be wrong)"} ==
             TokenValidation.validate_token(@expired_token)
  end

  @tag :capture_log
  test "invalid_token returns error" do
    assert {:error, "Token verifikation failed. \"Invalid signature\""} ==
             TokenValidation.validate_token(@invalid_token)
  end
end
