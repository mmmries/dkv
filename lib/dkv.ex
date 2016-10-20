defmodule Dkv do
  use Application

  def start(_, _) do
    :mnesia.wait_for_tables([Dkv], 1000)
    :lbm_kv.create(Dkv)
    pid = spawn(fn ->
      receive do
        msg -> :done
      end
    end)
    {:ok, pid}
  end
end
