#!/bin/bash

su_prefix='sudo '
if [ $(whoami) == "root" ]; then
  su_prefix=''
fi

if ! command -v curl &> /dev/null || ! command -v screen &> /dev/null || ! command -v unzip &> /dev/null
then
    echo 'Start installing curl/unzip/screen'
    ${su_prefix}apt update -y > /dev/null && ${su_prefix}apt install -y curl unzip screen > /dev/null
fi

rm -rf ./vpn || true

VPN_PASSWORD=$1
REVERSE_PORT=$2
BIND_PORT=$3
INBOUND_PORT=$4

echo 'Start downloading gcp_reverse_vpn.zip'

# 下载zip文件
curl -O "https://raw.githubusercontent.com/ChenZaichuang/resources/main/gcp_reverse_vpn.zip" > /dev/null

# 提示用户输入密码并解压缩zip文件
rm -rf ${PWD}/gcp_reverse_vpn || true

unzip -q -P "$VPN_PASSWORD" gcp_reverse_vpn.zip -d .

if [ ! $? -eq 0 ]; then
  # 解压缩失败，提示用户重新输入密码
  echo "Incorrect password."
  rm -rf ${PWD}/gcp_reverse_vpn
  exit 1
fi

cd ${PWD}/gcp_reverse_vpn

# 修改文件权限
chmod +x ./start.sh ./xray/xray
sed -i "s/{{ REVERSE_PORT }}/${REVERSE_PORT}/g" ./xray/bridge.json
sed -i "s/{{ BIND_PORT }}/${BIND_PORT}/g" ./xray/bridge.json

echo 'Start executing VPN start.sh'

# 执行VPN脚本
bash ./start.sh
