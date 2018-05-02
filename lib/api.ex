defmodule ExConduit.API do
  def add_mime_type(:get, :flow, opts) do
    Keyword.put(opts, :accept, "application/vnd.com.leadconduit.flow+json")
  end
  def add_mime_type(:get, :event, opts) do
    Keyword.put(opts, :accept, "application/vnd.com.leadconduit.event+json")
  end
end