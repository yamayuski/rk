#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Initializing Gemini CLI DevContainer Firewall...${NC}"

# Function to add allowed domain
add_allowed_domain() {
    local domain=$1
    local ip_list=$(dig +short "$domain" 2>/dev/null | grep -E '^[0-9.]+$' || echo "")

    if [ -n "$ip_list" ]; then
        for ip in $ip_list; do
            ipset -! add allowed_ips "$ip" 2>/dev/null || true
        done
        echo -e "${GREEN}✓${NC} Added $domain"
    else
        echo -e "${YELLOW}⚠${NC} Could not resolve $domain"
    fi
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Clean up any existing rules
echo "Cleaning up existing firewall rules..."
iptables -F OUTPUT 2>/dev/null || true
iptables -F INPUT 2>/dev/null || true
ipset destroy allowed_ips 2>/dev/null || true

# Create ipset for allowed IPs
echo "Creating IP allowlist..."
ipset create allowed_ips hash:ip

# Essential services
echo -e "\n${YELLOW}Adding essential services...${NC}"
add_allowed_domain "dns.google"
add_allowed_domain "1.1.1.1"
add_allowed_domain "8.8.8.8"
add_allowed_domain "8.8.4.4"

# Google Gemini API endpoints
echo -e "\n${YELLOW}Adding Google Gemini API endpoints...${NC}"
add_allowed_domain "generativelanguage.googleapis.com"
add_allowed_domain "aistudio.google.com"
add_allowed_domain "accounts.google.com"
add_allowed_domain "oauth2.googleapis.com"
add_allowed_domain "www.googleapis.com"
add_allowed_domain "content.googleapis.com"
add_allowed_domain "storage.googleapis.com"

# NPM and Node.js
echo -e "\n${YELLOW}Adding NPM registry endpoints...${NC}"
add_allowed_domain "registry.npmjs.org"
add_allowed_domain "registry.npmmirror.com"
add_allowed_domain "npm.pkg.github.com"
add_allowed_domain "nodejs.org"
add_allowed_domain "jsr.io"
add_allowed_domain "npm.jsr.io"
add_allowed_domain "deno.land"

# GitHub
echo -e "\n${YELLOW}Adding GitHub endpoints...${NC}"
add_allowed_domain "github.com"
add_allowed_domain "api.github.com"
add_allowed_domain "raw.githubusercontent.com"
add_allowed_domain "github.githubassets.com"
add_allowed_domain "collector.github.com"
add_allowed_domain "ghcr.io"
add_allowed_domain "pkg-containers.githubusercontent.com"

# Package CDNs
echo -e "\n${YELLOW}Adding package CDNs...${NC}"
add_allowed_domain "unpkg.com"
add_allowed_domain "cdn.jsdelivr.net"
add_allowed_domain "cdnjs.cloudflare.com"

# Development tools
echo -e "\n${YELLOW}Adding development tool endpoints...${NC}"
add_allowed_domain "deb.debian.org"
add_allowed_domain "security.debian.org"
add_allowed_domain "archive.ubuntu.com"
add_allowed_domain "security.ubuntu.com"

# Apply firewall rules
echo -e "\n${YELLOW}Applying firewall rules...${NC}"

# Allow localhost
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS queries
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow connections to allowed IPs
iptables -A OUTPUT -m set --match-set allowed_ips dst -j ACCEPT

# Allow HTTPS to allowed IPs
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed_ips dst -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m set --match-set allowed_ips dst -j ACCEPT

# Log dropped packets (optional, can be commented out)
# iptables -A OUTPUT -j LOG --log-prefix "DROPPED: " --log-level 4

# Default policy: DROP all other outbound traffic
iptables -A OUTPUT -j DROP

echo -e "\n${GREEN}✓ Firewall initialization complete!${NC}"
echo -e "${YELLOW}Note: Only connections to allowed services are permitted.${NC}"

# Save the current ipset for debugging
echo -e "\n${YELLOW}Allowed IPs:${NC}"
ipset list allowed_ips | grep -E '^[0-9.]+' | head -20
echo -e "${YELLOW}... and more${NC}"
