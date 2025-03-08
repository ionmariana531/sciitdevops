mkdir -p virtualbox/provisioning/{web,db,common}

# Create common provisioning script
cat << 'EOF' > virtualbox/provisioning/common/base_setup.sh
#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install common tools
sudo apt-get install -y \
  curl \
  wget \
  vim \
  git \
  htop \
  net-tools

# Configure timezone
sudo timedatectl set-timezone UTC

# Set up monitoring
sudo apt-get install -y prometheus-node-exporter
EOF

# Create web server provisioning
cat << 'EOF' > virtualbox/provisioning/web/setup_web.sh
#!/bin/bash

# Install web server
sudo apt-get install -y nginx

# Configure NGINX
sudo tee /etc/nginx/conf.d/default.conf << 'CONF'
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /var/www/html;
        index index.html;
    }
}
CONF

# Restart NGINX
sudo systemctl restart nginx
EOF

# Create database server provisioning
cat << 'EOF' > virtualbox/provisioning/db/setup_db.sh
#!/bin/bash

# Install MySQL
sudo apt-get install -y mysql-server

# Secure MySQL installation
sudo mysql_secure_installation

# Configure MySQL for remote access
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
EOF