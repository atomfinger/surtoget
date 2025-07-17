defmodule VixHelper do
  alias Vix.Vips.{Image}

  def read(path) do
    Path.expand(path) |> Image.new_from_file()
  end

  def to_bit_array(image, format) do
    Image.write_to_stream(image, format) |> Enum.into(<<>>)
  end

  def fetch_image_bytes(url, format \\ "png") do
    with {:ok, %Req.Response{status: 200, body: body}} <- Req.get(url),
         {:ok, image} <- Vix.Vips.Image.new_from_buffer(body, ""),
         {:ok, binary} <- Vix.Vips.Image.write_to_buffer(image, "." <> format) do
      {:ok, binary}
    else
      _ -> {:error, "Could not fetch or convert image"}
    end
  end

  def fetch_image(url) when is_binary(url) do
    IO.inspect(url, label: "Fetching image from URL")

    try do
      response = Req.get!(url)

      case response do
        %Req.Response{status: 200, body: body} ->
          case Vix.Vips.Image.new_from_buffer(body, []) do
            {:ok, image} ->
              {:ok, image}

            {:error, reason} ->
              {:error, "VIPS decode error: #{inspect(reason)}"}
          end

        %Req.Response{status: status} ->
          {:error, "HTTP request failed with status #{status}"}
      end
    rescue
      e in RuntimeError ->
        {:error, "Request exception: #{Exception.message(e)}"}
    end
  end
end
