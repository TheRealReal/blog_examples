defmodule Client do
  def concurrent_requests(number_of_requests \\ 5, delay \\ 100) do
    1..number_of_requests
    |> Enum.map(fn _ ->
        Task.async(fn -> Client.HTTP.get_resource(delay) end)
        end)
    |> Enum.map(&Task.await/1)
    |> Enum.each(fn {:ok, elapsed, message} ->
      IO.puts("Response = #{message}; Real Delay = #{elapsed}ms" )
    end)
  end
end
