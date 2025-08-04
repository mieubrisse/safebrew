#!/bin/bash
set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t' # Stricter word splitting

# 1. Extract Docker DNS info BEFORE any flushing
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)

# Flush existing rules and delete existing ipsets
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# 2. Selectively restore ONLY internal Docker DNS resolution
if [ -n "$DOCKER_DNS_RULES" ]; then
    echo "Restoring Docker DNS rules..."
    iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
    echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
else
    echo "No Docker DNS rules to restore"
fi

# First allow DNS and localhost before any restrictions
# Allow outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
# Allow inbound DNS responses
iptables -A INPUT -p udp --sport 53 -j ACCEPT
# Allow outbound SSH
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
# Allow inbound SSH responses
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Create ipset with CIDR support
ipset create allowed-domains hash:net

# Fetch GitHub meta information and aggregate + add their IP ranges
echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta | jq -r '.git[], .web[], .api[], .hooks[], .pages[]' | sort -u)
for range in $gh_ranges; do
    ipset add allowed-domains "$range" 2>/dev/null || echo "Failed to add $range"
done

# Add Go module proxy and checksum database
go_proxy_ips=$(dig +short proxy.golang.org | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
for ip in $go_proxy_ips; do
    ipset add allowed-domains "$ip/32" 2>/dev/null || echo "Failed to add Go proxy IP $ip"
done

sum_db_ips=$(dig +short sum.golang.org | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
for ip in $sum_db_ips; do
    ipset add allowed-domains "$ip/32" 2>/dev/null || echo "Failed to add Go sum DB IP $ip"
done

# Add common Go-related domains
echo "Adding Go-related domains..."
go_domains=("golang.org" "go.dev" "pkg.go.dev")
for domain in "${go_domains[@]}"; do
    domain_ips=$(dig +short "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    for ip in $domain_ips; do
        ipset add allowed-domains "$ip/32" 2>/dev/null || echo "Failed to add $domain IP $ip"
    done
done

# Add Anthropic API endpoints
echo "Adding Anthropic API endpoints..."
anthropic_domains=("api.anthropic.com" "claude.ai")
for domain in "${anthropic_domains[@]}"; do
    domain_ips=$(dig +short "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    for ip in $domain_ips; do
        ipset add allowed-domains "$ip/32" 2>/dev/null || echo "Failed to add $domain IP $ip"
    done
done

# Add NPM registry
echo "Adding NPM registry..."
npm_ips=$(dig +short registry.npmjs.org | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
for ip in $npm_ips; do
    ipset add allowed-domains "$ip/32" 2>/dev/null || echo "Failed to add NPM IP $ip"
done

# Allow HTTPS traffic to allowed domains
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed-domains dst -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m set --match-set allowed-domains src -m state --state ESTABLISHED -j ACCEPT

# Allow HTTP traffic to allowed domains (for redirects)
iptables -A OUTPUT -p tcp --dport 80 -m set --match-set allowed-domains dst -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m set --match-set allowed-domains src -m state --state ESTABLISHED -j ACCEPT

# Log and drop everything else
iptables -A OUTPUT -j LOG --log-prefix "BLOCKED-OUT: "
iptables -A OUTPUT -j DROP
iptables -A INPUT -j LOG --log-prefix "BLOCKED-IN: "
iptables -A INPUT -j DROP

echo "Firewall initialized with secure defaults for Go development with Claude Code"