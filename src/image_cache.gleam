import gleam/bool
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/list
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

@external(erlang, "Elixir.Vix.Vips.Operation", "resize")
fn resize_ffi(img: Image, scale: Float) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Image", "width")
fn get_width(image: Image) -> Int

type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
  PNG
  WebP(quality: Int, keep_metadata: Bool)
  AVIF(quality: Int, keep_metadata: Bool)
}

pub type ImageCacheMessage {
  GetCachedImage(String, process.Subject(Result(bytes_tree.BytesTree, Nil)))
  AddImage(String, bytes_tree.BytesTree)
}

pub type State {
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
      process.send(reply_to, dict.get(state.cache, id))
      actor.continue(state)
    }
    AddImage(id, image) -> {
      state.cache
      |> dict.insert(id, image)
      |> State()
      |> actor.continue()
    }
  }
}

pub fn start() -> Result(
  actor.Started(process.Subject(ImageCacheMessage)),
  actor.StartError,
) {
  let pid_actor =
    actor.new(State(dict.new()))
    |> actor.on_message(handle_message)
    |> actor.start()

  // Ensuring that we're loading images async while also avoiding blocking
  // request going to the site.
  let _ = case pid_actor {
    Ok(pid) -> {
      news.get_news_articles()
      |> list.each(fn(article) {
        process.spawn(fn() { load_image(pid.data, article) })
      })
      Ok(Nil)
    }
    Error(_) -> Error(Nil)
  }
  pid_actor
}

pub fn get_cached_image(
  id: String,
  actor: process.Subject(ImageCacheMessage),
) -> Result(bytes_tree.BytesTree, Nil) {
  let cache_result: Result(bytes_tree.BytesTree, Nil) =
    process.call(actor, 100, fn(reply_to) { GetCachedImage(id, reply_to) })
  case cache_result {
    Ok(image) -> Ok(image)
    Error(_) -> load_default_image()
  }
}

fn load_image(
  actor: process.Subject(ImageCacheMessage),
  article: news.NewsArticle,
) {
  let image_id = news.get_image_id(article)
  let image = cache_image(article) |> result.unwrap(bytes_tree.new())
  process.send(actor, AddImage(image_id, image))
}

fn cache_image(article: news.NewsArticle) -> Result(bytes_tree.BytesTree, Nil) {
  case fetch_image_from_external_source(article.external_image_url) {
    Ok(image) -> {
      let image_type = AVIF(80, False)
      // Just defaulting to 600 as that is the max size an image will take up with our layout anyway.
      let image_max_size = 600
      let scale_ratio =
        int.to_float(image_max_size) /. int.to_float(get_width(image))
      case resize_ffi(image, scale_ratio) {
        Ok(resized_image) -> {
          to_bit_array(resized_image, image_type)
          |> bytes_tree.from_bit_array()
          |> Ok()
        }
        Error(_) -> load_default_image()
      }
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
