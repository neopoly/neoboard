defmodule Neoboard.Widgets.GitlabCi.Fetcher do
  defmodule Project do
    @derive [Poison.Encoder]
    defstruct [:id, :name, :url, :default_branch, :build_status, :failed?]

    def from_json(json) do
      %__MODULE__{
        id: json["id"],
        name: json["name"],
        url: json["web_url"],
        default_branch: default_branch(json),
        failed?: false
      }
    end

    def fill_build_status(project, build_status_json) do
      failed = build_status_json |> Enum.find(&(&1["status"] == "failed"))
      if failed do
        %{project |
          build_status: failed["status"],
          url: failed["web_url"],
          failed?: true
        }
      else
        project
      end
    end

    defp default_branch(json) do
      case Map.get(json, "default_branch") do
        nil -> "master"
        ""  -> "master"
        val -> val
      end
    end
  end

  alias Neoboard.Widgets.GitlabCi.Fetcher

  defstruct [:api_url, :private_token, :per_page, :options, projects: []]

  def fetch_projects(api_url, private_token, per_page, timeout) do
    %Fetcher{
      api_url: api_url,
      private_token: private_token,
      per_page: per_page,
      options: [timeout: timeout, recv_timeout: timeout],
    } |> fetch_projects
  end

  defp fetch_projects(fetcher) do
    fetcher = fetcher
    |> collect_projects
    |> collect_build_status

    {:ok, fetcher.projects}
  end

  defp collect_projects(fetcher = %Fetcher{api_url: api_url, per_page: per_page}, url \\ nil) do
    url = url || "#{api_url}/projects?per_page=#{per_page}&archived=false"
    {:ok, response = %HTTPoison.Response{status_code: 200}} = fetch(fetcher, url)
    {next, collected} = parse_response(response)
    fetcher = %{fetcher | projects: fetcher.projects ++ collected}
    case next do
      nil -> fetcher
      _ -> collect_projects(fetcher, next)
    end
  end

  defp collect_build_status(fetcher = %Fetcher{projects: projects}) do
    projects = projects
    |> Task.async_stream(&(get_build_status(&1, fetcher)), max_concurrency: 8)
    |> Enum.map(fn {:ok, val} -> val end)
    |> Enum.to_list
    %{fetcher | projects: projects}
  end

  defp get_build_status(project, fetcher) do
    url = "#{fetcher.api_url}/projects/#{project.id}/pipelines?per_page=1&ref=#{project.default_branch}"
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = fetch(fetcher, url)
    Project.fill_build_status(project, parse_body(body))
  end

  defp fetch(%Fetcher{private_token: private_token, options: options}, url) do
    headers = [{"PRIVATE-TOKEN", private_token}]
    HTTPoison.get(url, headers, options)
  end

  defp parse_response(%HTTPoison.Response{body: body, headers: headers}) do
    {extract_next(headers), parse_body(body) |> to_projects}
  end

  defp extract_next(headers) do
    headers
    |> Enum.find_value(fn {name, value} -> name == "Link" && value end)
    |> extract_rel_next
  end

  defp extract_rel_next(nil) do
    nil
  end

  defp extract_rel_next(value) do
    case Regex.run(~r/<([^>]+)>; rel="next"/, value, capture: :all_but_first) do
      nil -> nil
      list -> List.first(list)
    end
  end

  defp to_projects(json) do
    json |> Enum.filter_map(&(&1["jobs_enabled"]), &Project.from_json/1)
  end

  defp parse_body(body) do
    body |> Poison.decode!
  end
end
