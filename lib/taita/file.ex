defmodule Taita.File do
  defstruct kind: "drive#file", id: nil, name: nil, mimeType: nil, description: nil,
            starred: nil, trashed: nil, explicitlyTrashed: nil, parents: nil,
            properties: nil, appProperties: nil, spaces: nil, version: nil,
            webContentLink: nil, webViewLink: nil, iconLink: nil, thumbnailLink: nil,
            viewedByMe: nil, viewedByMeTime: nil, createdTime: nil, modifiedTime: nil,
            modifiedByMeTime: nil, sharedWithMeTime: nil, 
            sharingUser: %Taita.User{}, owners: [%Taita.User{}],
            lastModifyingUser: %Taita.User{}, shared: nil, ownedByMe: nil,
            # capabilities: %Taita.Capabilities{}, viewersCanCopyContent: nil,
            writersCanShare: nil, permissions: [%Taita.Permission{}],
            folderColorRgb: nil, originalFilename: nil, fullFileExtension: nil,
            fileExtension: nil, md5Checksum: nil, size: nil, quotaBytesUsed: nil,
            headRevisionId: nil, contentHints: nil, imageMediaMetadata: nil, 
            videoMediaMetadata: nil, isAppAuthorized: nil
  use Taita.Base
  
  def create(:with_file, resource_list, params, upload_source, options \\ []) do
    do_create_file(resource_list, params, options, upload_source)
    |> handle_resp(as: struct(__MODULE__))
  end

  def update(:with_file, resource_list, params, upload_source, options \\ []) do
    do_update_file(resource_list, params, options, upload_source)
    |> handle_resp(as: struct(__MODULE__))
  end

  defp do_create_file(resource_list, params, options, upload_source) do
    {headers, body} = mp_related_headers_and_body(params, upload_source)
    post "upload/", body, headers, [params: options]
  end

  def do_update_file(resource_list, params, options, upload_source) do
    {headers, body} = mp_related_headers_and_body(params, upload_source)
    patch "upload/#{List.first(resource_list).id}", body, headers, [params: options]
  end

  defp mp_related_headers_and_body(params, upload_source) do
    boundary = random_string 16
    body = """
    --#{boundary}
    Content-Type: application/json; charset=UTF-8

    #{params |> Enum.into(%{}) |> Poison.encode!}
    #{gen_file_content(upload_source, boundary)}
    --#{boundary}--
    """
    headers = [
      "content-type": "multipart/related; boundary=#{boundary}",
      "content-length": byte_size(body)
    ]
    {headers, body}
  end

  defp gen_file_content(nil, _boundary) do
    ""
  end

  defp gen_file_content(file_name, boundary) do
    case File.read(file_name) do
      {:ok, file_content} ->
        """

        --#{boundary}
        Content-Type: #{file_name |> MIME.from_path}

        #{file_content}
        """
      :error ->
        gen_file_content(nil, boundary)
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
