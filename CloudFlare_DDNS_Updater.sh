#!/bin/bash

# Get public IP
IP=$(curl -s https://api.ipify.org)
if [[ -z "$IP" ]]; then
  echo "Could not get public IP."
  exit 1
fi

# Your Cloudflare API Token (replace with your actual token)
CF_API_TOKEN="YOUR_CLOUDFLARE_API_TOKEN_HERE"

# Declare an array of zones and root domains
declare -A ZONES=(
  ["example1.com"]="zoneid_1"
  ["example2.com"]="zoneid_2"
)

# Function to update a single record
update_record() {
  local zone_name=$1
  local zone_id=$2
  local record_name=$3

  # Look up record ID
  record_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$record_name" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json")

  record_id=$(echo "$record_response" | jq -r '.result[0].id')
  current_ip=$(echo "$record_response" | jq -r '.result[0].content')

  if [[ "$current_ip" != "$IP" && "$record_id" != "null" ]]; then
    echo "Updating $record_name in $zone_name to $IP"
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}" > /dev/null
  fi
}

# Loop through all zones and update wildcard A records only
for domain in "${!ZONES[@]}"; do
  zone_id="${ZONES[$domain]}"
  update_record "$domain" "$zone_id" "*.$domain"
done
