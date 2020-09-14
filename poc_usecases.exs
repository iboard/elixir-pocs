defprotocol Usecase do
  def request(usecase, opts \\ [])
  def execute(usecase)
  def args(usecase)
  def result(usecase)
  def errors(usecase)
  def state(usecase)
  def entity(usecase)
  def client(usecase)
end

defmodule Clean do
  defmacro __using__(_opts) do
    quote do
      defstruct request: nil, errors: [], result: nil, halt: false, client: :system

      defimpl Usecase, for: __MODULE__ do
        def request(usecase, ... = opts \\ []) do
          %{usecase | request: opts}
        end

        def execute(args) do
          if !args.halt do
            case args.__struct__.execute(args.request) do
              {:ok, _} = r -> %{args | result: r}
              {:error, error} = e -> %{args | result: e, errors: args.errors ++ [error]}
              result -> %{args | result: result}
            end
          else
            args
          end
        end

        def result(usecase), do: usecase.result
        def client(usecase), do: usecase.client
        def errors(usecase), do: usecase.errors
        def args(usecase), do: usecase.request

        def state(usecase) do
          case usecase.result do
            {:ok, _} -> :ok
            {:error, _} -> :error
            x -> x
          end
        end

        def entity(usecase) do
          case Usecase.state(usecase) do
            :ok -> usecase.result |> elem(1)
            :error -> nil
            x -> x
          end
        end
      end
    end
  end
end

defmodule DateUsecase do
  use Clean
  def execute(nil), do: NaiveDateTime.utc_now()
  def execute(y: y, m: m, d: d), do: NaiveDateTime.new(y, m, d, 0, 0, 0)
end

defmodule FizzbarUsecase do
  use Clean
  def execute(_params), do: "Fizzefazze!"
end

defmodule MyApp do
  def run() do
    ## Usecase without params, no request() neccessary
    %DateUsecase{}
    |> Usecase.execute()
    |> IO.inspect(label: "result")

    IO.puts("")

    ## Same usecase but with input parameters
    uc =
      %DateUsecase{}
      |> Usecase.request(y: 1964, m: 08, d: 31)
      |> Usecase.execute()

    uc
    |> Usecase.args()
    |> IO.inspect(label: "args")

    uc
    |> Usecase.client()
    |> IO.inspect(label: "client")

    uc
    |> Usecase.result()
    |> IO.inspect(label: "result")

    uc
    |> Usecase.errors()
    |> IO.inspect(label: "errors")

    uc
    |> Usecase.state()
    |> IO.inspect(label: "state")

    uc
    |> Usecase.entity()
    |> IO.inspect(label: "entity")

    IO.puts("")

    ## Same usecase but with invalid input
    uc =
      %DateUsecase{}
      |> Usecase.request(y: 1964, m: 2, d: 30)
      |> Usecase.execute()

    uc
    |> Usecase.args()
    |> IO.inspect(label: "args")

    uc
    |> Usecase.result()
    |> IO.inspect(label: "result")

    uc
    |> Usecase.errors()
    |> IO.inspect(label: "errors")

    uc
    |> Usecase.state()
    |> IO.inspect(label: "state")

    uc
    |> Usecase.entity()
    |> IO.inspect(label: "entity")

    IO.puts("")

    %FizzbarUsecase{}
    |> Usecase.execute()
    |> Usecase.result()
    |> IO.inspect(label: "result")

    IO.puts("")

    %DateUsecase{}
    |> Usecase.execute()
    |> Usecase.entity()
    |> IO.inspect(label: "Today is")
  end
end

MyApp.run()
