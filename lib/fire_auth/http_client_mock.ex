defmodule FireAuth.HttpClientMock do
  def get!(_, _options \\ []) do
    {:ok, body} = File.read("test/google-keys.json")
    %{body: body}
  end
end
