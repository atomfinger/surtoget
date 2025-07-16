import gleam/bool
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/otp/actor
import gleam/string
import news

pub type Image

@external(erlang, "Elixir.VixHelper", "to_bit_array")
fn to_bit_array_ffi(img: Image, format: String) -> bit_array

@external(erlang, "Elixir.VixHelper", "fetch_image")
fn fetch_image_ffi(url: String) -> Result(Image, String)

type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
  PNG
  WebP(quality: Int, keep_metadata: Bool)
  AVIF(quality: Int, keep_metadata: Bool)
}

pub type ImageCacheMessage {
  GetCachedImage(String, process.Subject(Result(Image, Nil)))
  PutCachedImage(String, Image)
}

type State {
  State(cache: dict.Dict(String, Image))
}

fn to_bit_array(img: Image, format: ImageFormat) -> BitArray {
  to_bit_array_ffi(img, image_format_to_string(format))
}

fn image_format_to_string(format: ImageFormat) -> String {
  case format {
    JPEG(quality:, keep_metadata:) ->
      ".jpeg" <> format_common_options(quality, keep_metadata)
    PNG -> ".png"
    WebP(quality:, keep_metadata:) ->
      ".webp" <> format_common_options(quality, keep_metadata)
    AVIF(quality:, keep_metadata:) ->
      ".avif" <> format_common_options(quality, keep_metadata)
  }
}

fn format_common_options(quality, keep_metadata) {
  "[Q="
  <> int.to_string(quality)
  <> ",strip="
  <> bool.to_string(!keep_metadata) |> string.lowercase
  <> "]"
}

fn handle_message(
  state: State,
  message: ImageCacheMessage,
) -> actor.Next(State, ImageCacheMessage) {
  let State(cache) = state

  case message {
    GetCachedImage(id, reply_to) -> {
      process.send(reply_to, dict.get(cache, id))
      actor.continue(state)
    }
    PutCachedImage(id, image) -> {
      let new_cache = dict.insert(cache, id, image)
      actor.continue(State(new_cache))
    }
  }
}

pub fn start() -> Result(
  actor.Started(process.Subject(ImageCacheMessage)),
  actor.StartError,
) {
  actor.new(State(dict.new()))
  |> actor.on_message(handle_message)
  |> actor.start()
}

pub fn get_cached_image(
  id: String,
  actor: process.Subject(ImageCacheMessage),
) -> Result(bytes_tree.BytesTree, Nil) {
  let image_type = JPEG(80, False)
  case process.call(actor, 100, fn(reply_to) { GetCachedImage(id, reply_to) }) {
    Ok(image) ->
      Ok(
        image
        |> to_bit_array(image_type)
        |> bytes_tree.from_bit_array(),
      )
    Error(_) -> Error(Nil)
  }
}

pub fn fetch_and_cache_image(
  article: news.NewsArticle,
  actor: process.Subject(ImageCacheMessage),
) -> Result(bytes_tree.BytesTree, Nil) {
  let image_id: String = news.get_image_id(article)
  case fetch_image_ffi(article.external_url) {
    Ok(image) -> {
      process.send(actor, PutCachedImage(image_id, image))
      get_cached_image(image_id, actor)
    }
    Error(_) -> Error(Nil)
  }
}
