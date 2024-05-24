# Check if Docker is installed
if command -v docker &>/dev/null; then
    echo "Docker is installed. Running docker-compose.exporters.yml..."
    # Assuming you have docker-compose installed as well
    docker-compose up -d
else
    echo "Docker is not installed. Installing Node Exporter..."
    # Install Node Exporter using systemd
    sudo useradd --no-create-home --shell /bin/false node_exporter
    sudo mkdir -p /var/lib/node_exporter/textfile_collector
    sudo chown -R node_exporter:node_exporter /var/lib/node_exporter
    curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
    sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
    rm -rf node_exporter-1.7.0.linux-amd64.tar.gz node_exporter-1.7.0.linux-amd64
    sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start node_exporter
    sudo systemctl enable node_exporter
    echo "Node Exporter installed and started successfully."
fi
