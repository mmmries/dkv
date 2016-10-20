defmodule Dkv do
  use Application

  def start(_, _) do
    :lbm_kv.create(Dkv)
    pid = spawn(fn ->
      receive do
        msg -> :done
      end
    end)
    {:ok, pid}
  end
end
