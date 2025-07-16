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

  def fetch_image(url) do
    with {:ok, %Req.Response{status: 200, body: body}} <- Req.get(url),
         {:ok, image} <- Vix.Vips.Image.new_from_buffer(body, "") do
      {:ok, image}
    else
      _ -> {:error, "Failed to fetch or decode image"}
    end
  end
end
