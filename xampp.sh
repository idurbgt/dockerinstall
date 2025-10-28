#!/bin/bash
# Script: setup-xampp-autostart.sh
# Pastikan dijalankan dengan hak root atau sudo

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
# Jika ingin restart otomatis ketika gagal
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "Mengatur permission …"
chmod 644 "${SERVICE_FILE}"

echo "Reload systemd daemon …"
systemctl daemon-reload

echo "Enable service xampp …"
systemctl enable xampp.service
