defmodule Taita.Base do
  defmacro __using__(_) do
    quote do
      use HTTPoison.Base
      alias Goth.Token

      defp api do
        "https://www.googleapis.com/drive/v3"
      end

      defp gen_token do
        Token.for_scope("https://www.googleapis.com/auth/drive")
      end

      defp authorization_header(%{token: token, type: type}) do
        ["Authorization": "#{type} #{token}"]
      end

      defp process_request_headers([authorization: authorization] = headers) do
        headers
      end

      defp process_request_headers(headers) do
        {_, token} = gen_token
        Keyword.merge(headers, authorization_header(token))
      end

      def process_url(url) do
        case url do
          "upload/" <> file_id ->
            "https://www.googleapis.com/upload/drive/v3/files/#{file_id}?uploadType=multipart"
          _ ->
            api <> url
        end
      end

      defp handle_resp({:ok, resp}, decode_params \\ []) do
        case resp.status_code do
          200 ->
            resp.body |> Poison.decode(decode_params)
          204 ->
            {:ok, %{}}
          _ ->
            {:error, Poison.decode!(resp.body)}
        end
      end

      defp json_headers_and_body(params) do
        body = params |> Enum.into(%{}) |> Poison.encode!
        headers = [
          "content-type": "application/json",
          "content-length": byte_size(body)
        ]
        {headers, body}
      end

      def path do
        Regex.run(~r/(?<=\.)[A-Za-z]*$/, Atom.to_string(__MODULE__))
          |> List.first
          |> String.downcase
          |> Inflex.pluralize
      end

      def resource_path([]) do
        ""
      end

      def resource_path(resource_list) do
        do_resource_path("", resource_list)
      end

      def do_resource_path(pre, []) do
        pre
      end

      def do_resource_path(pre, [resource | rest]) do
        do_resource_path(pre <> "/" <> resource_name_pluralize(resource) <> resource_path_id_part(resource), rest)
      end

      def resource_path_id_part(%{id: id}) when not is_nil(id) do
        "/#{id}"
      end

      def resource_path_id_part(_) do
        ""
      end

      def resource_name_pluralize(resource) do
        resource.__struct__
        |> Atom.to_string
        |> String.split(".")
        |> List.last
        |> String.downcase
        |> Inflex.pluralize
      end

      def create(resource_list, params, options \\ []) do
        {headers, body} = json_headers_and_body(params)
        resource_list
        |> resource_path
        |> post(body, headers, options)
        |> handle_resp(as: struct(__MODULE__))
      end

      def index(resource_list, options \\ []) do
        resource_list
        |> resource_path
        |> get([], options)
        |> handle_resp(as: %{path => [struct(__MODULE__)]})
      end

      def show(resource_list, options \\ []) do
        resource_list
        |> resource_path
        |> get([], options)
        |> handle_resp(as: struct(__MODULE__))
      end

      def destroy(resource_list) do
        resource_list
        |> resource_path
        |> delete
        |> handle_resp
      end

      def update(resource_list, params, options \\ []) do
        {headers, body} = json_headers_and_body(params)
        resource_list
        |> resource_path
        |> patch(body, headers, options)
        |> handle_resp(as: struct(__MODULE__))
      end
    end
  end
end