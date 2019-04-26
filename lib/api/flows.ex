defmodule ExConduit.API.Flows do
  @moduledoc """
  The Flow is the primary unit of work in LeadConduit. When a lead is 
  submitted to LeadConduit, the flow ID is specified and the lead is 
  processed according to the instructions in that flow.
  """

  @typedoc """
  Options for [`Flows.get/1`](#get/1).
  - `:authorization` (REQUIRED) -- A string containing the LeadConduit account API key.
  - `:flow_id` (OPTIONAL) -- A string containing the Flow ID.
  """
  @type get_opts :: [get_opt]
  @type get_opt :: {:authorization, String.t()} | {:flow_id, String.t()}

  @spec get(opts :: get_opts) :: ExConduit.Request.t()
  def get(opts \\ []) do
    path =
      case opts[:flow_id] do
        nil -> "/flows"
        _ -> "/flows/#{opts[:flow_id]}"
      end

    opts = Keyword.delete(opts, :flow_id)
    opts = ExConduit.API.add_mime_type(:get, :flow, opts)

    %ExConduit.Request{
      verb: :get,
      path: path,
      opts_schema: %{authorization: {:header, :required}, accept: {:header, :required}},
      opts: Map.new(opts)
    }
  end
end
