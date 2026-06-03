import os
from PIL import Image, ImageDraw

def make_outer_transparent():
    src_path = "/Users/afif/.gemini/antigravity/brain/532f997a-4f1f-40a8-b440-748b6753bf59/app_icon_option4_1780418577809.png"
    dest_path = "/Users/afif/Documents/antigravity/busy-nobel/assets/app_icon.png"
    
    img = Image.open(src_path).convert("RGBA")
    width, height = img.size
    
    # マスク画像を作成し、外側の白い領域だけをFlood Fillで検出
    # (0, 0) は必ず外側の白い領域であるため、ここから塗りつぶしを開始
    mask = Image.new("L", (width + 2, height + 2), 0)
    
    # 接続性のある白い背景を検出 (閾値: RGBが220以上)
    # PILのfloodfillでシード(0,0)から白に近い部分のみマスクを1にする
    # floodfillを自前でシンプルな探索として実装
    pixels = img.load()
    visited = set()
    queue = [(0, 0)]
    visited.add((0, 0))
    
    while queue:
        cx, cy = queue.pop(0)
        # 近傍4ピクセルを探索
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited:
                    r, g, b, a = pixels[nx, ny]
                    # 白っぽい色（外枠の背景）であれば進む
                    if r > 215 and g > 215 and b > 215:
                        visited.add((nx, ny))
                        queue.append((nx, ny))
                        
    # 訪問した「外側の白いピクセル」のみアルファを0（透明）にする
    new_data = []
    datas = img.getdata()
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if (x, y) in visited:
                new_data.append((255, 255, 255, 0)) # 外側の背景だけを透明化
            else:
                new_data.append((r, g, b, a)) # アイコン内部（ハブの白い線も含む）はそのまま
                
    img.putdata(new_data)
    
    # 余白を切り抜く (透明でないコンテンツのバウンディングボックスを取得)
    bbox = img.getbbox()
    if bbox:
        # 完全に外枠の背景だけを削除し、中のアイコン形状を維持したまま切り抜き
        img = img.crop(bbox)
        
    img.save(dest_path, "PNG")
    print("Successfully removed ONLY the outer white background and kept internal elements.")

if __name__ == "__main__":
    make_outer_transparent()
