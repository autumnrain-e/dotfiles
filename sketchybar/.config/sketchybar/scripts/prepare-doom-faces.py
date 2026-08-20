#!/usr/bin/env python3
"""Knock out white-matted edges and resize Doom HUD faces for the logo chip.

The source PNGs are keyed against white, but the anti-aliased silhouette is
still opaque off-white/beige. Three passes at full resolution, then pad to
square and nearest-neighbour down to 32px:

1. Flood-fill from existing transparency into desaturated light pixels.
   Skin/teeth/blood/eyes are interior and more chromatic, so they stay.
2. Erode the opaque mask by 1px (4-connected). The leftover halo is mixed
   beige, not pure white, so the color flood misses it; peeling the whole
   ring is what actually clears the chip.
3. Flood again for any beige the new edge still exposes.

Usage:
  python3 prepare-doom-faces.py [source_dir] [dest_dir]
"""

from __future__ import annotations

import sys
from collections import deque
from pathlib import Path

from PIL import Image

LUMA_MIN = 160
CHROMA_MAX = 40
ERODE_LUMA_MIN = 150
ERODE_CHROMA_MAX = 50
CANVAS = 110
SIZE = 32


def luma(r: int, g: int, b: int) -> float:
    return 0.299 * r + 0.587 * g + 0.114 * b


def chroma(r: int, g: int, b: int) -> int:
    return max(r, g, b) - min(r, g, b)


def knock_white_matte(
    im: Image.Image, luma_min: float = LUMA_MIN, chroma_max: int = CHROMA_MAX
) -> Image.Image:
    im = im.convert("RGBA")
    pix = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] == 0:
                pix[x, y] = (0, 0, 0, 0)

    def is_fringe(x: int, y: int) -> bool:
        r, g, b, a = pix[x, y]
        if a == 0:
            return True
        return luma(r, g, b) >= luma_min and chroma(r, g, b) <= chroma_max

    q: deque[tuple[int, int]] = deque()
    seen = [[False] * w for _ in range(h)]
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] == 0:
                seen[y][x] = True
                q.append((x, y))
    while q:
        x, y = q.popleft()
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if not (0 <= nx < w and 0 <= ny < h) or seen[ny][nx]:
                continue
            if is_fringe(nx, ny):
                seen[ny][nx] = True
                pix[nx, ny] = (0, 0, 0, 0)
                q.append((nx, ny))
    return im


def erode_alpha(im: Image.Image) -> Image.Image:
    """Drop every opaque pixel that touches a transparent one (4-connected)."""
    im = im.convert("RGBA")
    pix = im.load()
    w, h = im.size
    kill: list[tuple[int, int]] = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] == 0:
                continue
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if not (0 <= nx < w and 0 <= ny < h) or pix[nx, ny][3] == 0:
                    kill.append((x, y))
                    break
    for x, y in kill:
        pix[x, y] = (0, 0, 0, 0)
    return im


def prepare(im: Image.Image) -> Image.Image:
    im = knock_white_matte(im)
    im = erode_alpha(im)
    return knock_white_matte(im, luma_min=ERODE_LUMA_MIN, chroma_max=ERODE_CHROMA_MAX)


def to_chip(im: Image.Image) -> Image.Image:
    sq = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    x = (CANVAS - im.size[0]) // 2
    y = (CANVAS - im.size[1]) // 2
    sq.paste(im, (x, y), im)
    return sq.resize((SIZE, SIZE), Image.NEAREST)


def main() -> int:
    here = Path(__file__).resolve()
    default_dest = here.parents[1] / "assets" / "doom"
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / "Downloads" / "doom_faces"
    dest = Path(sys.argv[2]) if len(sys.argv) > 2 else default_dest
    if not src.is_dir():
        print(f"source not found: {src}", file=sys.stderr)
        return 1

    dest.mkdir(parents=True, exist_ok=True)
    count = 0
    for png in sorted(src.glob("*/*.png")):
        out = dest / png.parent.name / png.name
        out.parent.mkdir(parents=True, exist_ok=True)
        to_chip(prepare(Image.open(png))).save(out)
        count += 1
        print(f"{png.relative_to(src)} -> {out.relative_to(dest)}")
    print(f"wrote {count} faces to {dest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
