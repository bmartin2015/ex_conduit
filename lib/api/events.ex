defmodule ExConduit.API.Events do
  @moduledoc """
  An event tracks what happened with a lead at a particular step in 
  a flow. An event is a self-contained snapshot of the state of the 
  lead at the time the lead visited the step. It contains a full copy 
  of all lead data, along with all data that was appended before that 
  step.
  """

  @typedoc """
  Options for [`Flows.get/1`](#get/1).
  - `:authorization` (REQUIRED) -- A string containing the LeadConduit account API key.
  - `:lead_id` (OPTIONAL) -- A string containing the Flow ID.
  """

  def get(opts \\ []) do
    opts = ExConduit.API.add_mime_type(:get, :event, opts)
    %ExConduit.Request{
      verb: :get,
      path: "/events",
      opts_schema: %{authorization: {:header, :required}, accept: {:header, :required},
        after_id: {:query, :optional}, before_id: {:query, :optional}, 
        start: {:query, :optional}, end: {:query, :optional}, type: {:query, :optional},
        lead_id: {:query, :optional}, reference: {:query, :optional}, 
        flow_id: {:query, :optional}, source_id: {:query, :optional}, 
        recipient_id: {:query, :optional}, outcome: {:query, :optional}, 
        limit: {:query, :optional}, sort: {:query, :optional}},
      opts: Map.new(opts)
    }
  end  
end


