#!/usr/bin/env bash
# Ubuntu 22.04 / 24.04 sunucusunu node çalıştırmaya hazırlar.
# Kullanım: sudo bash setup/sunucu-hazirlik.sh
# Tekrar çalıştırmak güvenlidir; zaten yapılmış adımları atlar.
set -euo pipefail

SWAP_GB="${SWAP_GB:-8}"
SSH_PORT="${SSH_PORT:-22}"

if [[ $EUID -ne 0 ]]; then
  echo "Bu betik root olarak çalışmalı: sudo bash $0" >&2
  exit 1
fi

. /etc/os-release
if [[ "$ID" != "ubuntu" ]]; then
  echo "Uyarı: Bu betik Ubuntu için yazıldı (bulunan: $PRETTY_NAME)." >&2
fi

echo "==> Sistem paketleri güncelleniyor"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg git jq htop tmux ufw fail2ban \
  unattended-upgrades lz4 wget build-essential

echo "==> Docker kuruluyor"
if ! command -v docker >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
systemctl enable --now docker

# Container logları diski doldurmasın
if [[ ! -f /etc/docker/daemon.json ]]; then
  cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "50m", "max-file": "3" }
}
EOF
  systemctl restart docker
fi

if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
  usermod -aG docker "$SUDO_USER"
fi

echo "==> Swap (${SWAP_GB} GB)"
if ! swapon --show | grep -q /swapfile; then
  fallocate -l "${SWAP_GB}G" /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "==> Güvenlik duvarı (UFW)"
ufw default deny incoming
ufw default allow outgoing
ufw allow "${SSH_PORT}/tcp"
ufw --force enable

echo "==> fail2ban ve otomatik güvenlik güncellemeleri"
systemctl enable --now fail2ban
dpkg-reconfigure -f noninteractive unattended-upgrades

echo
echo "Hazır. Docker grubunun etkin olması için oturumu kapatıp yeniden aç."
echo "Bir node'un P2P portunu açmak için: sudo ufw allow <port>/tcp"
