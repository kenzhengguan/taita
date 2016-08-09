defmodule Taita.Comment do
  defstruct kind: "drive#comment", id: nil, author: [%Taita.User{}],
            htmlContent: nil, content: nil, createdTime: nil, modifiedTime: nil,
            deleted: nil, resolved: nil, quotedFileContent: nil, anchor: nil,
            replies: nil
  use Taita.Base
end
