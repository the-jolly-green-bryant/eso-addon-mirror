"""Resize icons to 128x128 RGBA and write uncompressed A8R8G8B8 DDS for ESO.

NOTE (Holodeck 0.0.8+): Early custom DDS often rendered as opaque white in
SPACE_WORLD. Prefer stock ESO POI paths for enemies/spots.

Role icons: ship DM2-proven textures as hd_tank / hd_healer / hd_dps.dds
(copied from DeadMarker2/textures). Do not overwrite those with this script
unless you know the export is SPACE_WORLD-safe.

This script is optional art tooling only.
"""
import os
import struct
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SESSION_IMG = r"C:\Users\fredg\.grok\sessions\D%3A%5Cdev%5CESOAddons%5CDeadMarker_Holodeck\019fc904-7e22-75e2-a293-923f1ebbf69e\images"

# source jpg -> dest stem  (legacy; not preferred for SPACE_WORLD)
MAP = {
    "4.jpg": "hd_boss",
    "7.jpg": "hd_miniboss",
    "6.jpg": "hd_stack",
    "5.jpg": "hd_origin",
    "3.jpg": "hd_dot",
    "2.jpg": "hd_ring",
}
# Roles: use copy of DeadMarker2 dm2tank/healer/dps instead of this MAP.


def write_dds_bgra(path, img: Image.Image):
    """Uncompressed 32-bit DDS (A8R8G8B8 / BGRA)."""
    img = img.convert("RGBA")
    w, h = img.size
    # DDS pixel format flags
    DDSD_CAPS = 0x1
    DDSD_HEIGHT = 0x2
    DDSD_WIDTH = 0x4
    DDSD_PITCH = 0x8
    DDSD_PIXELFORMAT = 0x1000
    DDSD_LINEARSIZE = 0x80000
    DDPF_ALPHAPIXELS = 0x1
    DDPF_RGB = 0x40
    DDSCAPS_TEXTURE = 0x1000

    pitch = w * 4
    flags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH | DDSD_PITCH | DDSD_PIXELFORMAT
    # header
    header = bytearray(128)
    struct.pack_into("<4sIIIIIII", header, 0, b"DDS ", 124, flags, h, w, pitch, 0, 0)
    # pixel format at offset 76
    pf_size = 32
    pf_flags = DDPF_RGB | DDPF_ALPHAPIXELS
    # BGRA masks for A8R8G8B8 in DDS often listed as R G B A bitmasks for R8G8B8A8
    # ESO typically accepts standard D3DFMT_A8R8G8B8: A=ff000000 R=00ff0000 G=0000ff00 B=000000ff
    rmask, gmask, bmask, amask = 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000
    struct.pack_into(
        "<IIIIIIII",
        header,
        76,
        pf_size,
        pf_flags,
        0,  # fourCC
        32,  # RGB bit count
        rmask,
        gmask,
        bmask,
        amask,
    )
    struct.pack_into("<I", header, 108, DDSCAPS_TEXTURE)

    pixels = bytearray()
    data = img.tobytes()  # RGBA
    for i in range(0, len(data), 4):
        r, g, b, a = data[i], data[i + 1], data[i + 2], data[i + 3]
        pixels += bytes((b, g, r, a))  # BGRA

    with open(path, "wb") as f:
        f.write(header)
        f.write(pixels)


def process(src_name, stem):
    src = os.path.join(SESSION_IMG, src_name)
    im = Image.open(src).convert("RGBA")
    # scale to fit 128 with padding
    im.thumbnail((128, 128), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    ox = (128 - im.width) // 2
    oy = (128 - im.height) // 2
    canvas.paste(im, (ox, oy), im)
    png_path = os.path.join(HERE, stem + ".png")
    dds_path = os.path.join(HERE, stem + ".dds")
    canvas.save(png_path, "PNG")
    write_dds_bgra(dds_path, canvas)
    print("wrote", png_path, dds_path, canvas.size)


def main():
    for src, stem in MAP.items():
        process(src, stem)
    print("done")


if __name__ == "__main__":
    main()
