defmodule Dkv.Mixfile do
  use Mix.Project

  def project do
    [app: :dkv,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :lbm_kv]]
  end

  defp deps do
    [
      {:lbm_kv, "~> 0.0.2"},
    ]
  end
end
