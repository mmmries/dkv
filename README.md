# dkv

And example project that uses `lbm_kv` to show how you can have a consistent distributed key-value store in Elixir.

# 1 - install lbm_kv

> see tag [step1](https://github.com/mmmries/dkv/tree/step1)

* `mix.exs` add dependency and app
* `config/config.exs` sasl only log errors


```
$ iex -S mix
iex(1)> :lbm_kv.create(Dkv)
:ok
iex(2)> :lbm_kv.get(Dkv, :ron)
{:ok, []}
iex(3)> :lbm_kv.put(Dkv, :ron, "swanson")
{:ok, []}
iex(4)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
```

__Now let's do that distributed__

Get your IP address and do:

```
$ iex --name dkv@YOUR_IP --cookie monster -S mix
iex(1)> :lbm_kv.create(Dkv)
:ok
iex(2)> :lbm_kv.get(Dkv, :ron)
{:ok, []}
iex(3)> :lbm_kv.put(Dkv, :ron, "swanson")
{:ok, []}
iex(4)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
```

Now from a second session do

```
$ iex --name dkv2@YOUR_IP --cookie monster -S mix
iex(1)> Node.ping(:"dkv@YOUR_IP")
:pong
iex(2)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
```

# 2 - create kv store in supervision tree

> see tag [step2](https://github.com/mmmries/dkv/tree/step2)

* `mix.exs`
* `lib/dkv.ex`
* `sys.config`

First session

```
$ iex --name dkv@YOUR_IP --cookie monster --erl '-config sys.config' -S mix
iex(1)> :lbm_kv.put(Dkv, :ron, "swanson")
{:ok, []}
iex(2)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
```

Second session

```
$ iex --name dkv2@YOUR_IP --cookie monster --erl '-config sys.config' -S mix
iex(1)> :lbm_kv.get(Dkv, :ron)
{:ok, []}
iex(2)> :lbm_kv.put(Dkv, :ben, "Wyatt")
{:ok, []}
```

Back in the first session

```
iex(3)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
iex(4)> :lbm_kv.get(Dkv, :ben)
{:ok, [ben: "Wyatt"]}
```

__WAT?!?!?!__

![crazy pills](http://gifrific.com/wp-content/uploads/2012/04/i-feel-like-im-taking-crazy-pills.gif)

# 3 - The Solution

> see tag [step3](https://github.com/mmmries/dkv/tree/step3)

[mnesia documentation](http://erlang.org/doc/apps/mnesia/Mnesia_chap3.html) in section `Startup Procedure`.

* `lib/dkv.ex`

First session

```
$ iex --name dkv@YOUR_IP --cookie monster --erl '-config sys.config' -S mix
iex(1)> :lbm_kv.put(Dkv, :ron, "swanson")
{:ok, []}
iex(2)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
```

Second session

```
$ iex --name dkv2@YOUR_IP --cookie monster --erl '-config sys.config' -S mix
iex(1)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
iex(2)> :lbm_kv.put(Dkv, :ben, "Wyatt")
{:ok, []}
```

Back in the first session

```
iex(3)> :lbm_kv.get(Dkv, :ron)
{:ok, [ron: "swanson"]}
iex(4)> :lbm_kv.get(Dkv, :ben)
{:ok, [ben: "Wyatt"]}
```

# Final Notes

Performed some [benchmarks](https://gist.github.com/mmmries/54c2110bb93af61ebfa1aff36acec9ca) and did 9,200 consistent writes per second in a cluster of 3 nodes.

For a cheap benchmark in your system you can do:

```elixir
:timer.tc(fn ->
  (1..10000) |> Enum.each(&( :lbm_kv.put(Dkv, :"key_#{&1}", {&1, "string #{&1}"}) ))
end)
```

That will give you the number of microseconds it took to store 10k key-value pairs into your distributed cluster
```
