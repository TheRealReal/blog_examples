# Server

To start your this server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Endpoints

- `/resource`: sample resource endpoint, returns a text body.
  - Query options:
    - `delay`: the time, in milliseconds, this endpoint will wait before returning
