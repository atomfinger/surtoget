import gleam/bool
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/result
import gleam/string
import news
import snag
import wisp

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
  CacheImages
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
  case message {
    GetCachedImage(id, reply_to) -> {
      wisp.log_debug("Testing")
      io.println("Getting " <> id)
      process.send(reply_to, dict.get(state.cache, id))
      io.println("Having returned it!")
      actor.continue(state)
    }
    CacheImages -> {
      let new_state: State =
        news.get_news_articles()
        |> list.map(with: fn(article) {
          #(
            news.get_image_id(article),
            cache_image(article) |> result.unwrap(bytes_tree.new()),
          )
        })
        |> list.filter(keeping: fn(pair) {
          let #(_, bytes) = pair
          bytes_tree.byte_size(bytes) != 0
        })
        |> dict.from_list()
        |> State()
      actor.continue(new_state)
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
  io.println("Asking for the damn results!")
  let cache_result: Result(bytes_tree.BytesTree, Nil) =
    process.call(actor, 100, fn(reply_to) { GetCachedImage(id, reply_to) })
  io.println("Got those darn results")
  case cache_result {
    Ok(image) -> Ok(image)
    Error(_) -> load_default_image()
  }
}

fn cache_image(article: news.NewsArticle) -> Result(bytes_tree.BytesTree, Nil) {
  case fetch_image_from_external_source(article.external_image_url) {
    Ok(image) -> {
      let image_type = AVIF(80, False)
      image
      |> to_bit_array(image_type)
      |> bytes_tree.from_bit_array()
      |> Ok()
    }
    Error(_) -> load_default_image()
  }
}

fn load_default_image() -> Result(bytes_tree.BytesTree, Nil) {
  case read("priv/static/train-placeholder.png") {
    Ok(image) -> {
      let image_type = PNG
      image
      |> to_bit_array(image_type)
      |> bytes_tree.from_bit_array()
      |> Ok()
    }
    Error(_) -> Error(Nil)
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
