defmodule Taita.Permission do
  defstruct kind: "drive#permission", id: nil, type: nil, emailAddress: nil, domain: nil,
            role: nil, allowFileDiscovery: nil, displayName: nil, photoLink: nil,
            expirationTime: nil
  use Taita.Base
end