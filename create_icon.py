import struct, zlib, os

def chunk(chunk_type, data):
    c = zlib.crc32(chunk_type + data) & 0xffffffff
    return struct.pack('>I', len(data)) + chunk_type + data + struct.pack('>I', c)

def make_gray_png(size, gray=176):
    ihdr = struct.pack('>IIBBBBB', size, size, 8, 0, 0, 0, 0)
    row = bytes([0]) + bytes([gray]) * size
    raw = row * size
    return (b'\x89PNG\r\n\x1a\n' +
            chunk(b'IHDR', ihdr) +
            chunk(b'IDAT', zlib.compress(raw)) +
            chunk(b'IEND', b''))

os.makedirs('AppIcon.iconset', exist_ok=True)

for name, size in [
    ('icon_16x16.png',      16),
    ('icon_16x16@2x.png',   32),
    ('icon_32x32.png',      32),
    ('icon_32x32@2x.png',   64),
    ('icon_128x128.png',   128),
    ('icon_128x128@2x.png',256),
    ('icon_256x256.png',   256),
    ('icon_256x256@2x.png',512),
    ('icon_512x512.png',   512),
    ('icon_512x512@2x.png',1024),
]:
    with open(f'AppIcon.iconset/{name}', 'wb') as f:
        f.write(make_gray_png(size))
    print(f'  {name}')

print('Done.')
