# Client

Demo http client with connection pool monitoring.

  * Install dependencies with `mix deps.get`
  * Compile the project with `mix compile`

## Running

This project is intended to run inside `iex`:

```
iex -S mix
```

The function you'll want to use is `Client.concurrent_requests/2`:

```
iex(1)> Client.concurrent_requests(10, 250)
```
