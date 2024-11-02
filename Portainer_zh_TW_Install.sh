#!/bin/bash

# 獲取當前腳本的絕對路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. 讓用戶選擇端口號
echo "--------------------------------------------"
while true; do
    read -p "--->>> 請輸入 Docker 服務的 Port (預設 443): " USER_PORT
    USER_PORT=${USER_PORT:-443}  # 若未輸入則設置為 443

    # 檢查輸入的 Port 是否為有效的數字且在範圍內
    if [[ "$USER_PORT" =~ ^[0-9]+$ ]] && ((USER_PORT >= 1 && USER_PORT <= 65535)); then
        echo "--->>> 使用的 Port 為：$USER_PORT"
        break
    else
        echo "無效的 Port，請輸入介於 1-65535 之間的數字。"
    fi
done

# 2. 更新系統
echo "--------------------------------------------"
echo "--->>> 更新系統..."
echo "--------------------------------------------"
sudo apt update && sudo apt upgrade -y

# 3. 安裝 Docker
echo "--------------------------------------------"
echo "--->>> 安裝 Docker及依賴項..."
echo "--------------------------------------------"
sudo apt install -y docker.io curl  unzip
sudo systemctl start docker
sudo systemctl enable docker

# 4. 建立資料夾 /opt/Portainer
sudo mkdir /opt/portainer_zhTW

# 5. 下載繁體中文資料檔案
echo "--------------------------------------------"
echo "--->>> 下載繁體漢化版資料中..."
echo "--------------------------------------------"
sudo wget -O "$SCRIPT_DIR/data.zip" $(curl -s https://api.github.com/repos/zz22558822/Portainer_zh_TW_Install/releases/latest | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)
sudo chmod -R 777 "$SCRIPT_DIR/data.zip"

# 6. 解壓縮覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 解壓縮繁體漢化版資料中..."
echo "--------------------------------------------"
sudo mkdir -p "/opt/portainer_zhTW"
sudo unzip -o "$SCRIPT_DIR/data.zip" -d "/opt/portainer_zhTW"
sudo rm -f "$SCRIPT_DIR/data.zip"

# 7. 設置權限
echo "--------------------------------------------"
echo "--->>> 正在設定資料權限..."
echo "--------------------------------------------"
sudo chmod -R 777 "/opt/portainer_zhTW"

# 8. 安裝 Portainer Docker 容器
echo "--------------------------------------------"
echo "--->>> 正在安裝 Portainer CE v2.19.4..."
echo "--------------------------------------------"
sudo docker run -d -p 8000:8000 -p $USER_PORT:9443 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/portainer_data:/data \
  -v /opt/portainer_zhTW/public:/public \
  portainer/portainer-ce:2.19.4

# 9. 設定 Docker 自動重啟 Portainer 容器
echo "--------------------------------------------"
echo "--->>> 正在設置 Portainer 自動重啟..."
echo "--------------------------------------------"
sudo docker update --restart unless-stopped portainer


# 10. 顯示訪問路徑
SERVER_IP=$(hostname -I | awk '{print $1}' | sed 's/[[:space:]]//g')
echo "--------------------------------------------"
echo "--->>> 訪問路徑: https://${SERVER_IP}:${USER_PORT}"
echo ""
echo "--->>> portainer 安裝完成。"
echo "--------------------------------------------"