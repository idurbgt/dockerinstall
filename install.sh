#!/bin/bash
# ============================================================
# Script: xampp-honeygain.sh
=====

set -e

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Harus dijalankan sebagai root atau dengan sudo."
  exit 1
fi

echo "==========================================="
echo "==> [1/3] Instalasi Docker Engine"
echo "==========================================="

apt update -y
apt remove -y docker docker-engine docker.io containerd runc || true
apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "==> Menambahkan GPG key resmi Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "==> Menambahkan repository Docker ke APT sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Mengaktifkan dan menjalankan layanan Docker..."
systemctl enable docker
systemctl start docker

echo "==> Verifikasi instalasi..."
docker --version
systemctl status docker --no-pager

echo
echo "=== Instalasi Docker selesai ==="
echo "Hanya root yang dapat menjalankan Docker."
echo

# ============================================================
# BAGIAN 2: Membuat systemd service autostart untuk XAMPP
# ============================================================

echo "==========================================="
echo "==> [2/3] Membuat Systemd Service untuk XAMPP"
echo "==========================================="

SERVICE_FILE="/etc/systemd/system/xampp.service"

echo "Membuat systemd service file untuk XAMPP di ${SERVICE_FILE} …"

cat << 'EOF' > "${SERVICE_FILE}"
[Unit]
Description=XAMPP auto start service
After=network.target

[Service]
Type=forking
ExecStart=/opt/lampp/lampp start
ExecStop=/opt/lampp/lampp stop
PIDFile=/opt/lampp/var/log/lampp.pid
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "${SERVICE_FILE}"
systemctl daemon-reload
systemctl enable xampp.service

echo "=== Systemd service untuk XAMPP berhasil dibuat ==="
echo

# ============================================================
# BAGIAN 3: Menjalankan container Honeygain
# ============================================================

echo "==========================================="
echo "==> [3/3] Menjalankan container Honeygain"
echo "==========================================="

echo "==> Menarik image honeygain/honeygain..."
docker pull honeygain/honeygain

echo "==> Menjalankan container baru honeygain_instance..."
docker run -d honeygain/honeygain -tou-get

echo
echo "=== Container Honeygain berhasil dijalankan ==="
echo
echo "==> STATUS AKHIR:"
echo "- Docker aktif"
echo "- XAMPP autostart aktif"
echo "- Container Honeygain berjalan"
echo
echo "Selesai ✅"
