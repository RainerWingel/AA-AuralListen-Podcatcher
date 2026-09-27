"""Generates the Android launcher and notification icons from source.webp.

Usage (needs Pillow + numpy, e.g. in a throwaway venv):
    python3 -m venv /tmp/iconvenv && /tmp/iconvenv/bin/pip install pillow numpy
    /tmp/iconvenv/bin/python tool/icon/make_icons.py tool/icon/source.webp \
        android/app/src/main/res /tmp/icon_preview.png

Writes per density: mipmap ic_launcher (legacy, transparent corners),
ic_launcher_foreground + ic_launcher_monochrome (adaptive icon layers) and
drawable ic_stat_podcast (white status bar silhouette). The background layer
is the gradient in res/drawable/ic_launcher_background.xml. Details:
docs/build-and-release.md.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

src, res, preview = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
rgb = Image.open(src).convert('RGB')
N = rgb.width
a = np.asarray(rgb).astype(np.float64)

# --- 1. Outer white corners -> transparent (legacy icon) ------------------
light = Image.fromarray(((a.min(axis=2) > 200) * 255).astype(np.uint8)).copy()
for c in [(0, 0), (N - 1, 0), (0, N - 1), (N - 1, N - 1)]:
    ImageDraw.floodfill(light, c, 128)
outer = np.asarray(light) == 128
ring = np.asarray(Image.fromarray((outer * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(7))) > 0
ring &= ~outer
g = a[..., 1]
edge_alpha = np.clip((255 - g) / (255 - 40), 0, 1)  # navy G ~ 10..45
alpha_legacy = np.where(outer, 0.0, np.where(ring, edge_alpha, 1.0))

def box_blur(x, r):
    # Three box passes per axis approximate a Gaussian; edges padded.
    for axis in (0, 1):
        for _ in range(3):
            pad = [(0, 0), (0, 0)]
            pad[axis] = (r + 1, r)
            c = np.cumsum(np.pad(x, pad, mode='edge'), axis=axis)
            hi = np.take(c, range(2 * r + 1, c.shape[axis]), axis=axis)
            lo = np.take(c, range(0, c.shape[axis] - 2 * r - 1), axis=axis)
            x = (hi - lo) / (2 * r + 1)
    return x


# --- 2. Estimate the background under the artwork (inpaint by blurring) ----
inside = ~outer & ~ring
fg0 = (a[..., 2] > 175) | (a[..., 1] > 60) | (a[..., 0] > 60)
known = inside & ~np.asarray(
    Image.fromarray((fg0 * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9))) .astype(bool)
bg = np.zeros_like(a)
w = known.astype(np.float64)
num = a * w[..., None]
for radius in (8, 24, 64, 160):
    blur = lambda x: box_blur(x, radius)
    wb = blur(w)
    est = np.stack([blur(num[..., i]) for i in range(3)], axis=2) / np.maximum(wb, 1e-6)[..., None]
    fill = (bg.sum(axis=2) == 0) & (wb > 1e-3)
    bg[fill] = est[fill]
bg[known] = a[known]

# --- 3. Key the foreground by the blue channel (all artwork has B ~ 250) ---
bgB = bg[..., 2]
alpha = np.clip((a[..., 2] - bgB - 6) / (252 - bgB - 6), 0, 1)
# Ignore the lighter rim of the source's rounded square (not artwork).
core = np.asarray(Image.fromarray((inside * 255).astype(np.uint8)).filter(ImageFilter.MinFilter(41))) > 0
alpha[~core] = 0
safe = np.maximum(alpha, 1e-3)[..., None]
fg = np.clip((a - (1 - alpha[..., None]) * bg) / safe, 0, 255)
fg_rgba = np.dstack([fg, alpha * 255]).astype(np.uint8)
fg_img = Image.fromarray(fg_rgba, 'RGBA')

# Adaptive icon layer: 108 dp. Farthest artwork point is ~582 px from the
# centre; map it to 31 dp so it stays inside the 66 dp safe zone of every mask.
cx = cy = N / 2
ys, xs = np.nonzero(alpha > 0.05)
rmax = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2).max()
layer_px = int(round(108 * rmax / 31))
layer = Image.new('RGBA', (layer_px, layer_px), (0, 0, 0, 0))
layer.paste(fg_img, ((layer_px - N) // 2, (layer_px - N) // 2))
white = Image.new('RGBA', layer.size, (255, 255, 255, 0))
white.putalpha(layer.getchannel('A'))

dens = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
legacy = Image.fromarray(np.dstack([a, alpha_legacy * 255]).astype(np.uint8), 'RGBA')
bbox = white.getbbox()
stat = white.crop(bbox)
side = max(stat.size)
stat_sq = Image.new('RGBA', (side, side), (255, 255, 255, 0))
stat_sq.paste(stat, ((side - stat.width) // 2, (side - stat.height) // 2))
for name, d in dens.items():
    mip = res / f'mipmap-{name}'
    mip.mkdir(exist_ok=True)
    legacy.resize((round(48 * d),) * 2, Image.LANCZOS).save(mip / 'ic_launcher.png', optimize=True)
    s = round(108 * d)
    layer.resize((s, s), Image.LANCZOS).save(mip / 'ic_launcher_foreground.png', optimize=True)
    white.resize((s, s), Image.LANCZOS).save(mip / 'ic_launcher_monochrome.png', optimize=True)
    dr = res / f'drawable-{name}'
    dr.mkdir(exist_ok=True)
    # Status bar icon: 24 dp with 1 dp padding, white silhouette.
    inner = round(22 * d)
    canvas = Image.new('RGBA', (round(24 * d),) * 2, (255, 255, 255, 0))
    off = (canvas.width - inner) // 2
    canvas.paste(stat_sq.resize((inner, inner), Image.LANCZOS), (off, off))
    canvas.save(dr / 'ic_stat_podcast.png', optimize=True)

# --- Preview: foreground over the XML gradient, masked by circle/squircle ---
P = 432
top, mid, bot = np.array([0x18, 0x2F, 0x9D]), np.array([0x06, 0x0D, 0x40]), np.array([0x04, 0x0B, 0x30])
rows = []
for y in np.linspace(0, 1, P):
    t = y / 0.45
    rows.append(top + (mid - top) * t if y < 0.45 else mid + (bot - mid) * ((y - 0.45) / 0.55))
grad = np.repeat(np.array(rows)[:, None, :], P, axis=1)
bgimg = Image.fromarray(grad.astype(np.uint8), 'RGB').convert('RGBA')
comp = Image.alpha_composite(bgimg, layer.resize((P, P), Image.LANCZOS))
vis = comp.crop((P // 6, P // 6, P - P // 6, P - P // 6))  # 72 dp visible
out = Image.new('RGBA', (vis.width * 4 + 60, vis.height + 20), (240, 240, 240, 255))
for i, shape in enumerate(['circle', 'squircle', 'mono', 'legacy']):
    m = Image.new('L', vis.size, 0)
    dm = ImageDraw.Draw(m)
    if shape == 'circle':
        dm.ellipse((0, 0, vis.width - 1, vis.height - 1), fill=255)
        tile = vis.copy(); tile.putalpha(m)
    elif shape == 'squircle':
        dm.rounded_rectangle((0, 0, vis.width - 1, vis.height - 1), radius=vis.width // 3, fill=255)
        tile = vis.copy(); tile.putalpha(m)
    elif shape == 'mono':
        dm.ellipse((0, 0, vis.width - 1, vis.height - 1), fill=255)
        tile = Image.new('RGBA', vis.size, (60, 70, 90, 255))
        wv = white.resize((P, P), Image.LANCZOS).crop((P // 6, P // 6, P - P // 6, P - P // 6))
        tile = Image.alpha_composite(tile, wv); tile.putalpha(m)
    else:
        tile = legacy.resize(vis.size, Image.LANCZOS)
    out.alpha_composite(tile, (10 + i * (vis.width + 13), 10))
st = Image.open(res / 'drawable-xxxhdpi' / 'ic_stat_podcast.png')
out.alpha_composite(Image.new('RGBA', (st.width + 8, st.height + 8), (40, 40, 40, 255)), (0, 0))
out.alpha_composite(st, (4, 4))
out.save(preview)
print('layer px', layer_px, 'rmax', round(rmax), 'fg alpha px', int((alpha > 0.5).sum()))
