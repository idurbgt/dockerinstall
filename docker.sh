#!/bin/bash
# ============================================
# Script: install_docker_root_only.sh
# Tujuan: Instalasi Docker Engine di Ubuntu 20.04.4 LTS
# (hanya root yang dapat menjalankan docker) + fungsi tambahan Honeygain
# ============================================

set -e

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Harus dijalankan sebagai root."
  exit 1
fi

echo "==> Memperbarui paket sistem..."
apt update -y

echo "==> Menghapus versi Docker lama (jika ada)..."
apt remove -y docker docker-engine docker.io containerd runc || true

echo "==> Menginstal dependensi..."
apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "==> Menambahkan GPG key resmi Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "==> Menambahkan repository Docker ke APT sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==> Memperbarui indeks paket..."
apt update -y

echo "==> Menginstal Docker Engine dan komponennya..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Mengaktifkan dan menjalankan layanan Docker..."
systemctl enable docker
systemctl start docker

echo "==> Verifikasi instalasi..."
docker --version
docker compose version
systemctl status docker --no-pager

echo
echo "=== Instalasi Docker selesai ==="
echo "Gunakan perintah berikut untuk menguji:"
echo "  docker run hello-world"
echo
echo "Catatan: hanya root yang dapat menjalankan Docker."

### --- Tambahan: menjalankan Honeygain container ---
echo
echo "==> Fungsi tambahan: pull & run Honeygain"

echo "==> Melakukan docker pull honeygain/honeygain"
docker pull honeygain/honeygain

echo "==> Menjalankan container honeygain/honeygain dengan opsi -tou-get"
docker run --name honeygain_instance honeygain/honeygain -tou-get

echo "=== Selesai menjalankan Honeygain container ==="
