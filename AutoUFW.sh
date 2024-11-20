#!/bin/bash

# Nombre del script: nombre_apellido_fw.sh
# Este script configura un firewall en Debian 12 utilizando ufw.

# Comprobar que el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi

# Instalar ufw

echo "Instalando ufw..."

apt install ufw

echo "Iniciando configuraciÃ³n del firewall..."

# 1. Borrado de reglas anteriores
echo "Borrando reglas anteriores..."
ufw --force reset

# 2. ConfiguraciÃ³n de polÃ­ticas por defecto
echo "Estableciendo polÃ­tica restrictiva por defecto..."
ufw default deny incoming   # Bloquear todas las conexiones entrantes
ufw default allow outgoing  # Permitir todas las conexiones salientes

# 3. Permitir conexiones desde la IP del host anfitriÃ³n (172.16.2.149)
echo "Permitiendo conexiones desde la IP del host anfitriÃ³n (172.16.2.149)..."
ufw allow from 172.16.2.149 to any port 22 proto tcp           # SFTP
ufw allow from 172.16.2.149 to any port 137:138 proto udp      # SMB
ufw allow from 172.16.2.149 to any port 139,445 proto tcp      # SMB
ufw allow from 172.16.2.149 to any port 161:162 proto udp      # SNMP
ufw allow from 172.16.2.149 to any port 31010:31110 proto tcp  # Rango TCP
ufw allow from 172.16.2.149 to any port 50505:50509 proto tcp  # Rango TCP
ufw allow from 172.16.2.149 to any port 50505:50509 proto udp  # Rango UDP

# 4. Abrir puertos para la IP 172.16.2.201
echo "Configurando reglas para la IP 172.16.2.201..."
ufw allow from 172.16.2.201 to any port 4444 proto udp         # Puerto UDP
ufw allow from 172.16.2.201 to any port 139,445                # SMB (PrecauciÃ³n)
ufw allow from 172.16.2.201 to any port 3389                  # RDP (PrecauciÃ³n)

# 5. Habilitar acceso a servicios de correo electrÃ³nico
echo "Habilitando acceso a servicios de correo electrÃ³nico..."
ufw allow to any port 25 proto tcp  # SMTP
ufw allow to any port 143 proto tcp # IMAP
ufw allow to any port 110 proto tcp # POP3

# 6. Permitir conexiones a MySQL/MariaDB
echo "Permitiendo conexiones a MySQL/MariaDB desde la subred 172.16.0.0/22..."
ufw allow from 172.16.0.0/22 to any port 3306 proto tcp

# 7. Limitar la tasa de conexiones
echo "Aplicando limitaciones de tasa para conexiones..."
ufw limit ssh                       # SSH
ufw limit to any port 25 proto tcp  # SMTP
ufw limit to any port 80 proto tcp  # HTTP
ufw limit to any port 443 proto tcp # HTTPS

# 8. Control granular de ICMP
echo "Aplicando control granular de ICMP..."
ufw allow proto icmp to any type 8   # Permitir Echo Request (ping)
ufw deny proto icmp to any type 0    # Bloquear Echo Reply
ufw deny proto icmp to any type 3    # Bloquear Destination Unreachable
ufw deny proto icmp to any type 5    # Bloquear Redirect
ufw deny proto icmp to any type 11   # Bloquear Time Exceeded

# Habilitar UFW
echo "Habilitando ufw..."
ufw --force enable

# Imprimir las reglas configuradas
echo "Reglas configuradas:"
ufw status verbose

echo "ConfiguraciÃ³n del firewall completada."
