# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :fire_auth,
  project_id: nil

if Mix.env() == :test do
  config :fire_auth,
    project_id: "nada-preview",
    # Time the test data was generated
    current_time: 1_503_350_512,
    # Mock the http client
    http_client: FireAuth.HttpClientMock
end
