# POCs And Examples


## Usecases with protocols (`poc_usecases`)

- defines a protocol for usecases
- supports "Clean Architecture" (Request -> Interactor -> Response)

### Example

#### Implement your usecase and define it's execute-function(s)

    defmodule DateUsecase do
      use Clean
      def execute(nil), do: NaiveDateTime.utc_now()
      def execute(y: y, m: m, d: d), do: NaiveDateTime.new(y, m, d, 0, 0, 0)
    end

#### Use it

**Get the current date**, a usecase without parameters

    %DateUsecase{}
    |> Usecase.execute()
    |> IO.inspect(label: "result")

**A Usecase defines and returns it's state in a struct like this**

    => result: %DateUsecase{
          client: :system,
          errors: [],
          halt: false,
          request: nil,
          result: ~N[2020-09-14 07:01:06.791240]
       }

**The same usecase but with parameters**

    uc =
      %DateUsecase{}
      |> Usecase.request(y: 1964, m: 08, d: 31)
      |> Usecase.execute()

The usecase is a struct as shown above and the protocol implements functions
to access the fields of the usecase. When working with such usecases, always
pass (pipe) the entire structure and use the following function to access its
state.

_Usecase.args(usecase)_

    uc
    |> Usecase.args()
    |> IO.inspect(label: "args")
    # => args: [y: 1964, m: 8, d: 31]

_Usecase.client(client)_ (current_user, remote_ip, whatever you need)

    uc
    |> Usecase.client()
    |> IO.inspect(label: "client")
    # => client: :system

_Usecase.result(usecase)_ (whatever the execute-function returns)

    uc
    |> Usecase.result()
    |> IO.inspect(label: "result")
    # => result: {:ok, ~N[1964-08-31 00:00:00]}


_Usecase.errors(usecase)_ (the list of errors which occurs during the lifetime of
the usecase)

    uc =
    %DateUsecase{}
    |> Usecase.request(y: 2020, m: 2, d: 31)
    |> Usecase.execute()
    # => %DateUsecase{....}

    uc
    |> Usecase.errors()
    # => {:error, :invalid_date}

_Usecase.state(usecase)_ Is either `:ok`, `:error`, or `unknown`

    uc
    |> Usecase.state()
    # => :error

_Usecase.entity(usecase)_ The plain value of the result

    uc =
    %DateUsecase{}
    |> Usecase.request(y: 1964, m: 8, d: 31)
    |> Usecase.execute()
    |> Usecase.entity()
    # => ~N[1964-08-31 00:00:00]



