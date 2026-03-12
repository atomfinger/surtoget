#!/usr/bin/env python3
"""
Build script: pre-fetches and resizes news article images.

Run during Docker build (or locally before deploying). Images are placed in
priv/static/news_images/ and are NOT committed to the repository.

Each image is identified by the SHA-1 hash of its source URL (uppercase hex),
matching the get_image_id/1 function in src/news.gleam.

Usage:
    pip install Pillow
    python3 scripts/fetch_news_images.py
"""

import hashlib
import os
import re
import sys
import urllib.request
from io import BytesIO

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow is required. Install with: pip install Pillow", file=sys.stderr)
    sys.exit(1)

OUTPUT_DIR = "priv/static/news_images"
MAX_WIDTH = 600
NEWS_GLEAM_PATH = "src/news.gleam"


def get_image_id(url: str) -> str:
    """Matches news.get_image_id/1 in news.gleam: SHA-1 of URL, uppercase hex."""
    return hashlib.sha1(url.encode()).hexdigest().upper()


def extract_image_urls() -> list[str]:
    """Parse external_image_url values directly from news.gleam."""
    with open(NEWS_GLEAM_PATH) as f:
        content = f.read()
    urls = re.findall(r'external_image_url:\s*"([^"]+)"', content)
    return [u for u in urls if u]


def fetch_and_process(url: str, output_path: str) -> bool:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()

        img = Image.open(BytesIO(data)).convert("RGB")

        if img.width > MAX_WIDTH:
            new_height = int(img.height * MAX_WIDTH / img.width)
            img = img.resize((MAX_WIDTH, new_height), Image.LANCZOS)

        img.save(output_path, "WEBP", quality=80)
        return True
    except Exception as e:
        print(f"  FAILED: {e}", file=sys.stderr)
        return False


def main() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    urls = extract_image_urls()
    print(f"Found {len(urls)} image URLs in {NEWS_GLEAM_PATH}")

    ok = failed = skipped = 0
    for url in urls:
        image_id = get_image_id(url)
        output_path = os.path.join(OUTPUT_DIR, f"{image_id}.webp")

        if os.path.exists(output_path):
            skipped += 1
            continue

        print(f"  Fetching {image_id[:12]}... ({url[:60]})")
        if fetch_and_process(url, output_path):
            ok += 1
        else:
            failed += 1

    print(f"\nDone: {ok} fetched, {skipped} skipped (cached), {failed} failed")
    if failed:
        print(f"WARNING: {failed} image(s) could not be fetched. "
              "They will show the placeholder image.", file=sys.stderr)


if __name__ == "__main__":
    main()
