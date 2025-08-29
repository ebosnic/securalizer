#!/bin/bash
# securelyzer.sh - Full Security Audit for any domain
# Checks DNSSEC, HTTPS headers, and email authentication (SPF, DKIM, DMARC)
# Usage: ./securelyzer.sh <domain> [resolver]

DOMAIN=$1
RESOLVER=${2:-1.1.1.1}

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain> [resolver]"
    exit 1
fi

echo "=============================="
echo " Full Security Audit for $DOMAIN"
echo "=============================="

# -------------------------------
# 1. DNSSEC Audit
# -------------------------------
RRSIG_COUNT=$(dig A "$DOMAIN" +dnssec +noall +answer | grep -c "RRSIG")
DNSKEY_COUNT=$(dig DNSKEY "$DOMAIN" +noall +answer | grep -c "DNSKEY")
AD_FLAG=$(dig A "$DOMAIN" +dnssec @"$RESOLVER" | grep "flags:" | grep -o "ad")

echo "DNSSEC:"
echo "Zone Signed: $([ $RRSIG_COUNT -gt 0 ] && echo 'YES ✅' || echo 'NO ❌')"
echo "DNSKEY Present: $([ $DNSKEY_COUNT -gt 0 ] && echo 'YES ✅' || echo 'NO ❌')"
echo "Validated by Resolver: $([ "$AD_FLAG" = "ad" ] && echo 'YES ✅' || echo 'NO ❌')"
echo "Number of RRSIG signatures: $RRSIG_COUNT"
echo ""

# -------------------------------
# 2. HTTPS Headers Audit
# -------------------------------
echo "HTTPS Headers:"
HEADERS=$(curl -s -D - -o /dev/null "https://$DOMAIN/")
check_header() {
    local HEADER=$1
    echo "$HEADERS" | grep -qi "$HEADER" && echo "YES ✅" || echo "NO ❌"
}

echo "HSTS: $(check_header 'Strict-Transport-Security')"
echo "CSP: $(check_header 'Content-Security-Policy')"
echo "X-Frame-Options: $(check_header 'X-Frame-Options')"
echo "X-Content-Type-Options: $(check_header 'X-Content-Type-Options')"
echo "Referrer-Policy: $(check_header 'Referrer-Policy')"
echo ""

# -------------------------------
# 3. Email Authentication Audit
# -------------------------------
echo "Email Authentication:"

# Get MX records
MX_SERVERS=$(dig MX "$DOMAIN" +short | awk '{print $2}')
if [ -z "$MX_SERVERS" ]; then
    echo "SPF: NO ❌ (no MX)"
    echo "DKIM: NO ❌ (no MX)"
    echo "DMARC: NO ❌ (no MX)"
else
    # SPF check
    SPF_RECORD=$(dig TXT "$DOMAIN" +short | grep -i "v=spf1")
    echo "SPF: $([ -n "$SPF_RECORD" ] && echo 'YES ✅' || echo 'NO ❌')"

    # DMARC check
    DMARC_RECORD=$(dig TXT "_dmarc.$DOMAIN" +short | grep -i "v=DMARC1")
    echo "DMARC: $([ -n "$DMARC_RECORD" ] && echo 'YES ✅' || echo 'NO ❌')"

    # DKIM check (ask user for selector; default 'default')
    SELECTOR=${3:-default}
    DKIM_RECORD=$(dig TXT "$SELECTOR._domainkey.$DOMAIN" +short)
    echo "DKIM ($SELECTOR): $([ -n "$DKIM_RECORD" ] && echo 'YES ✅' || echo 'NO ❌')"
fi

echo "=============================="

