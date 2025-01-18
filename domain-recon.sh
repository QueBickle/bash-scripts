#!/bin/bash
TARGET_DOMAIN=$1

echo "Performing WHOIS lookup for $TARGET_DOMAIN..."
whois $TARGET_DOMAIN > "${TARGET_DOMAIN}_whois.txt"

echo "Performing DNS resolution for $TARGET_DOMAIN..."
dig $TARGET_DOMAIN > "${TARGET_DOMAIN}_dns.txt"

echo "Data saved to ${TARGET_DOMAIN}_whois.txt and ${TARGET_DOMAIN}_dns.txt"
