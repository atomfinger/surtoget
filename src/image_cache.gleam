import gleam/bool
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/otp/actor
import gleam/result
import gleam/string
import news
import snag

pub type Image

@external(erlang, "Elixir.VixHelper", "to_bit_array")
fn to_bit_array_ffi(img: Image, format: String) -> bit_array

@external(erlang, "Elixir.VixHelper", "fetch_image")
fn fetch_image_ffi(url: String) -> Result(Image, String)

@external(erlang, "Elixir.VixHelper", "read")
fn read_ffi(from path: String) -> Result(Image, String)

type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
  PNG
  WebP(quality: Int, keep_metadata: Bool)
  AVIF(quality: Int, keep_metadata: Bool)
}

pub type ImageCacheMessage {
  GetCachedImage(String, process.Subject(Result(bytes_tree.BytesTree, Nil)))
  PutCachedImage(String, bytes_tree.BytesTree)
}

type State {
  State(cache: dict.Dict(String, bytes_tree.BytesTree))
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

// TODO: Need to parse URL to find image type, or it needs to be passed in somehow. 
pub fn get_cached_image(
  id: String,
  actor: process.Subject(ImageCacheMessage),
) -> Result(bytes_tree.BytesTree, Nil) {
  process.call(actor, 100, fn(reply_to) { GetCachedImage(id, reply_to) })
}

pub fn fetch_and_cache_image(
  article: news.NewsArticle,
  actor: process.Subject(ImageCacheMessage),
) -> Result(bytes_tree.BytesTree, Nil) {
  let image_id: String = news.get_image_id(article)
  //TODO: FIND IMAGE TYPE
  case fetch_image_from_external_source(article.external_image_url) {
    Ok(image) -> {
      let image_type = AVIF(80, False)
      let image_bytes =
        image
        |> to_bit_array(image_type)
        |> bytes_tree.from_bit_array()
      process.send(actor, PutCachedImage(image_id, image_bytes))
      get_cached_image(image_id, actor)
    }
    Error(_) ->
      case read("priv/static/train-placeholder.png") {
        Ok(image) -> {
          let image_type = PNG
          let image_bytes =
            image
            |> to_bit_array(image_type)
            |> bytes_tree.from_bit_array()
          process.send(actor, PutCachedImage(image_id, image_bytes))
          get_cached_image(image_id, actor)
        }
        Error(_) -> Error(Nil)
      }
  }
}

// TODO: Need to validate URL
fn fetch_image_from_external_source(url: String) -> Result(Image, String) {
  case url {
    "" -> Error("Invalid URL")
    _ -> fetch_image_ffi(url)
  }
}

fn read(from path: String) -> Result(Image, snag.Snag) {
  read_ffi(path)
  |> result.map_error(snag.new)
  |> snag.context("Unable to read image from file")
}
