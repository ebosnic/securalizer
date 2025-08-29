# Securelyzer 🛡️

Bismillah, peace and blessings upon our beloved Prophet Muhammad ﷺ

**Securelyzer** is a full security audit tool for **DNS, HTTPS, and email authentication**. It’s fully generic and works against any domain/TLD. Perfect for security audits, pentesting, and quick checks.

---

## Features

### DNSSEC Audit
- Checks if the zone is signed
- DNSKEY presence
- RRSIG signature count
- Validation by a DNS resolver

### HTTPS Headers Audit
- HSTS (`Strict-Transport-Security`)
- Content Security Policy (`CSP`)
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy

### Email Authentication Audit
- SPF
- DKIM (user can provide selector)
- DMARC

---

## Installation

```bash
git clone git@github.com:ebosnic/securalizer.git
cd securalizer
chmod +x securelyzer.sh


## Usage

# Basic usage (default resolver 1.1.1.1)
./securelyzer.sh example.com

# Custom resolver
./securelyzer.sh example.com 8.8.8.8

# Custom DKIM selector
./securelyzer.sh example.com 8.8.8.8 selector1

Example output

==============================
 Full Security Audit for bosnic.net
==============================
DNSSEC:
Zone Signed: YES ✅
DNSKEY Present: YES ✅
Validated by Resolver: YES ✅
Number of RRSIG signatures: 1

HTTPS Headers:
HSTS: YES ✅
CSP: YES ✅
X-Frame-Options: YES ✅
X-Content-Type-Options: YES ✅
Referrer-Policy: YES ✅

Email Authentication:
SPF: YES ✅
DMARC: YES ✅
DKIM (default): YES ✅
==============================

License:
This project is MIT licensed. Use it freely, but remember: Allah is our provider and protector.
