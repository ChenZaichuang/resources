#!/bin/bash

su_prefix='sudo '
if [ $(whoami) == "root" ]; then
  su_prefix=''
fi

if ! command -v curl &> /dev/null || ! command -v screen &> /dev/null || ! command -v unzip &> /dev/null
then
    ${su_prefix}apt update -y && ${su_prefix}apt install -y curl unzip screen
fi

rm -rf ./vpn || true

VPN_PASSWORD=$1

# 下载zip文件
curl -O "https://raw.githubusercontent.com/ChenZaichuang/resources/main/gcp_forward_vpn.zip"

# 提示用户输入密码并解压缩zip文件
rm -rf ${PWD}/gcp_forward_vpn || true

unzip -q -P "$VPN_PASSWORD" gcp_forward_vpn.zip -d .

if [ ! $? -eq 0 ]; then
  # 解压缩失败，提示用户重新输入密码
  echo "Incorrect password."
  rm -rf ${PWD}/gcp_forward_vpn
  exit 1
fi

cd ${PWD}/gcp_forward_vpn

# 修改文件权限
chmod +x ./start.sh ./frp/frpc ./xray/xray

# 执行VPN脚本
bash ./start.sh
