#!/bin/bash

# Comprobar que el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi

# Instalar ufw si no está instalado
echo "Instalando ufw..."
sudo apt install -y ufw

echo "Iniciando configuración del firewall..."

# 1. Borrado de reglas anteriores
echo "Borrando reglas anteriores..."
sudo ufw --force reset

# 2. Configuración de políticas por defecto
echo "Estableciendo política restrictiva por defecto..."
sudo ufw default deny incoming   # Bloquear todas las conexiones entrantes
sudo ufw default allow outgoing  # Permitir todas las conexiones salientes

# 3. Permitir conexiones desde la IP del host anfitrión (172.16.2.149)
echo "Permitiendo conexiones desde la IP del host anfitrión (172.16.2.149)..."
sudo ufw allow from 172.16.2.149 to any port 22 proto tcp           # SFTP
sudo ufw allow from 172.16.2.149 to any port 137:138 proto udp      # SMB
sudo ufw allow from 172.16.2.149 to any port 139,445 proto tcp      # SMB
sudo ufw allow from 172.16.2.149 to any port 161:162 proto udp      # SNMP
sudo ufw allow from 172.16.2.149 to any port 31010:31110 proto tcp  # Rango TCP
sudo ufw allow from 172.16.2.149 to any port 50505:50509 proto tcp  # Rango TCP
sudo ufw allow from 172.16.2.149 to any port 50505:50509 proto udp  # Rango UDP

# 4. Abrir puertos para la IP 172.16.2.201
echo "Configurando reglas para la IP 172.16.2.201..."
sudo ufw allow from 172.16.2.201 to any port 4444 proto udp         # Puerto UDP
sudo ufw allow from 172.16.2.201 to any port 139,445                # SMB (Precaución)
sudo ufw allow from 172.16.2.201 to any port 3389                   # RDP (Precaución)

# 5. Habilitar acceso a servicios de correo electrónico
echo "Habilitando acceso a servicios de correo electrónico..."
sudo ufw allow to any port 25 proto tcp  # SMTP
sudo ufw allow to any port 143 proto tcp # IMAP
sudo ufw allow to any port 110 proto tcp # POP3

# 6. Permitir conexiones a MySQL/MariaDB
echo "Permitiendo conexiones a MySQL/MariaDB desde la subred 172.16.0.0/22..."
sudo ufw allow from 172.16.0.0/22 to any port 3306 proto tcp

# 7. Limitar la tasa de conexiones
echo "Aplicando limitaciones de tasa para conexiones..."
sudo ufw limit ssh                       # SSH
sudo ufw limit to any port 25 proto tcp  # SMTP
sudo ufw limit to any port 80 proto tcp  # HTTP
sudo ufw limit to any port 443 proto tcp # HTTPS

# 8. Control granular de ICMP
echo "Aplicando control granular de ICMP con iptables..."

# Permitir únicamente ICMP de tipo 8 (Echo Request - ping)
sudo iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

# Bloquear ICMP de tipo 0 (Echo Reply)
sudo iptables -A INPUT -p icmp --icmp-type 0 -j DROP

# Bloquear ICMP de tipo 3 (Destination Unreachable)
sudo iptables -A INPUT -p icmp --icmp-type 3 -j DROP

# Bloquear ICMP de tipo 5 (Redirect)
sudo iptables -A INPUT -p icmp --icmp-type 5 -j DROP

# Bloquear ICMP de tipo 11 (Time Exceeded)
sudo iptables -A INPUT -p icmp --icmp-type 11 -j DROP

echo "Reglas de ICMP aplicadas correctamente."

# Habilitar UFW
echo "Habilitando ufw..."
sudo ufw --force enable

# Imprimir las reglas configuradas
echo "Reglas configuradas:"
sudo ufw status verbose

echo "Configuración del firewall completada."
