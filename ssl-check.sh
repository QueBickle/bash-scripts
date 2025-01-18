#!/bin/bash

# SSL Certificate Checker Script
TARGET_DOMAIN=$1

echo "Checking SSL certificate for $TARGET_DOMAIN..."
echo | openssl s_client -connect $TARGET_DOMAIN:443 2>/dev/null | openssl x509 -text > "${TARGET_DOMAIN}_ssl_cert.txt"

echo "SSL certificate details saved to ${TARGET_DOMAIN}_ssl_cert.txt"
