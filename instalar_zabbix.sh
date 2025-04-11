#!/bin/bash

# Zabbix 7.0 LTS en Ubuntu 24.04 con MariaDB y Apache
set -e

echo "➡️ Actualizando paquetes del sistema..."
sudo apt update && sudo apt upgrade -y

echo "➡️ Instalando dependencias necesarias..."
sudo apt install -y wget curl gnupg2 lsb-release software-properties-common

echo "➡️ Agregando el repositorio oficial de Zabbix 7.0 LTS..."
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
sudo apt update

echo "➡️ Instalando Zabbix server, frontend, agent y base de datos..."
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

echo "➡️ Configurando la base de datos..."
sudo systemctl enable mariadb
sudo systemctl start mariadb

DB_PASS="zabbixpass"

sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "➡️ Importando esquema de la base de datos..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p"$DB_PASS" zabbix

echo "➡️ Configurando Zabbix server con la contraseña de la base de datos..."
sudo sed -i "s/^# DBPassword=/DBPassword=$DB_PASS/" /etc/zabbix/zabbix_server.conf

echo "➡️ Habilitando servicios Zabbix y Apache..."
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

echo "✅ Instalación completada."
echo "🔗 Ahora accede vía navegador a: http://<IP_DE_TU_SERVIDOR>/zabbix"
echo "🧾 Usuario por defecto: Admin / Contraseña: zabbix"



