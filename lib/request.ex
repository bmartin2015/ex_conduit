defmodule ExConduit.RequestT do
  # Moving to Telsa!!!!

  @enforce_keys [
    :verb,
    :path
  ]

  defstruct [
    :verb,
    :path,
    opts_schema: %{},
    opts: %{}
  ]

  @type t :: %__MODULE__{
    verb: :get | :post | :put | :delete,
    path: String.t,
    opts_schema: %{atom => {:body | :query | :header, :required | :optional}},
    opts: %{atom => any}
  }

  @type request_opts :: [request_opt]
  @type request_opt :: {atom, any}

  @doc """
  Add options to a request
  """
  @spec options(req :: ExConduit.Request.t, opts :: request_opts) :: ExConduit.Request.t
  def options(req, []), do: req
  def options(req, opts), do: %{req | opts: Map.merge(req.opts, Map.new(opts))}

  def add_api_key(req, api_key) do
    encoded_key = Base.encode64("X:#{api_key}")
    options(req, [{:authorization, "Basic #{encoded_key}"}])
  end

  @base_url "https://next.leadconduit.com"

  @doc """
  Make a request
  """
  @spec run(t) :: {:ok, any} | {:error, any}
  def run(request) do
    case validate(request) do
      :ok ->
        do_run(request)
      other ->
        other
    end
  end

  @doc """
  Validate that the request is ready.
  """
  @spec validate(request :: t) :: :ok | {:error, String.t}
  def validate(request) do
    Enum.reduce(request.opts_schema, [], fn
      {key, {_, :required}}, acc ->
        case Map.has_key?(request.opts, key) do
          true ->
            acc
          false ->
            [key | acc]
        end
      _, acc ->
        acc
    end)
    |> case do
      [] ->
        :ok
      [missing_one] ->
        {:error, "missing option `#{inspect(missing_one)}`"}
      missing_many ->
        detail = Enum.map(missing_many, &"`#{inspect(&1)}`") |> Enum.join(", ")
        {:error, "missing options #{detail}"}
    end
  end

  defp do_run(request) do
    client = build_client(request)

    case Tesla.request(client, [method: request.verb, url: request.path]) do
      {:ok, resp} ->
        {:ok, resp}
      {:error, error}
        -> {:error, error}
    end
  end

  @spec build_client(ExConduit.REquest.t()) :: Telsa.Env.t()
  def build_client(request) do
    %{header: header, query: query} = encode_options(request)

    middleware = [
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, header},
      {Tesla.Middleware.Query, query}
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end


  @spec opts_by_location(request :: t) :: %{(:body | :query | :header) => %{atom => any}}
  def opts_by_location(request) do
    Enum.reduce(request.opts, %{body: %{}, query: %{}, header: %{}}, fn {key, value}, acc ->
      case Map.get(request.opts_schema, key) do
        {location, _} ->
          update_in(acc, [location], &Map.put(&1, key, value))
        _ ->
          acc
      end
    end)
  end

  @spec encode_options(request :: t) :: %{(:body | :query | :header) => String.t}
  def encode_options(request) do
    opts = opts_by_location(request)
    %{
      header: encode_options(:header, opts.header),
      body: encode_options(:body, opts.body),
      query: encode_options(:query, opts.query),
    }
  end

  @spec encode_options(:body | :query | :header, opts :: map) :: String.t | map() | Keyword.t()
  defp encode_options(:body, opts) when map_size(opts) == 0, do: ""
  # In the body, only support one option and just encode the value
  defp encode_options(:body, opts), do: Jason.encode!(opts |> Map.values |> hd)
  defp encode_options(:query, opts) when map_size(opts) == 0, do: []
  defp encode_options(:query, opts), do: Map.to_list(opts)
  defp encode_options(:header, opts) when map_size(opts) == 0, do: ""
  defp encode_options(:header, opts) do
    Enum.map(opts, fn({k, v}) ->
      k = k
      |> Atom.to_string()
      |> String.capitalize()

      {k, v}
    end)
  end
end
