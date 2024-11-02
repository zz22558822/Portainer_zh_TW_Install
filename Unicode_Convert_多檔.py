import re
import opencc
import os

# 原始 JavaScript 檔案名稱列表
source_files = [
    'main.f42eb69d1d82a1e31ffd.js',
    'vendor.03cfbabfeca7a584fa7a.js'
]

# 動態獲取 opencc 的配置文件目錄
config_path = os.path.join(os.path.dirname(opencc.__file__), 'config', 's2t')

# 初始化簡體到繁體的轉換
converter = opencc.OpenCC(config_path)

# 正則表達式匹配 `\\uXXXX` 格式的字串
pattern = re.compile(r"\\u[0-9a-fA-F]{4}")

def convert_to_traditional(match):
    unicode_str = match.group(0)  # 取得 `\\uXXXX` 字串
    simplified_char = unicode_str.encode().decode('unicode_escape')  # 解碼簡體字
    traditional_char = converter.convert(simplified_char)  # 簡體轉繁體
    return ''.join(f"\\u{ord(c):04x}" for c in traditional_char)  # 轉回 `\\uXXXX`

for source_file in source_files:
    # 生成新檔案名稱，格式為 原檔名 + "_Convert" + 副檔名
    base, ext = os.path.splitext(source_file)
    new_file = f"{base}_Convert{ext}"

    # 讀取 JavaScript 檔案
    with open(source_file, 'r', encoding='utf-8') as file:
        js_content = file.read()

    # 將簡體 Unicode 字串轉換為繁體 Unicode
    converted_js_content = pattern.sub(convert_to_traditional, js_content)

    # 將處理後的內容寫回新的檔案
    with open(new_file, 'w', encoding='utf-8') as file:
        file.write(converted_js_content)

    print(f"JavaScript 檔案 {source_file} 已成功轉換並另存為 {new_file}！")
