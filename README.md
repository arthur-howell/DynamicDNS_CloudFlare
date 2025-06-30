Cloudflare Dynamic DNS Updater

This script updates the wildcard A records (*.yourdomain.com) on Cloudflare to match your current public IP. It is useful for connections like Starlink, where your IP can change often and you want your subdomains to always resolve correctly.

⸻

FILES INCLUDED:

CloudFlare_DDNS_Updater.sh
- The main bash script that checks your current public IP and updates your wildcard A records for each domain listed.

CronTab
- A single line cron job entry that runs the script every 2 minutes.

⸻

REQUIREMENTS:
	•	bash (standard on most Linux systems)
	•	curl (used to get your current IP)
	•	jq (used to parse JSON returned by Cloudflare API)
	•	A Cloudflare API Token with permission to edit DNS
	•	Zone IDs for each domain you want to update

⸻

STEP 1: Create a Cloudflare API Token
	1.	Go to https://dash.cloudflare.com/profile/api-tokens
	2.	Click “Create Token”
	3.	Use the “Edit zone DNS” template
	4.	Choose the specific zones you want to allow updates for
	5.	Copy the generated API token and save it securely

⸻

STEP 2: Get Your Zone IDs
	1.	Go to your Cloudflare dashboard
	2.	Select your domain
	3.	On the Overview tab, scroll down to find the Zone ID
	4.	Copy it

Repeat this for each domain you want to manage.

⸻

STEP 3: Configure the Script

Open CloudFlare_DDNS_Updater.sh in your preferred text editor.
Replace the example token and zone list with your actual information.

Example:

CF_API_TOKEN=“your_cloudflare_api_token_here”

declare -A ZONES=(
[“yourdomain1.com”]=“zoneid1”
[“yourdomain2.net”]=“zoneid2”
)

Save the file and exit the editor.

⸻

STEP 4: Make the Script Executable

Run:

chmod +x CloudFlare_DDNS_Updater.sh

You can now run the script manually:

./CloudFlare_DDNS_Updater.sh

If your IP changed and the wildcard record exists, it will update the IP.

⸻

STEP 5: Install jq (if needed)

If you get an error about jq missing, install it:

sudo apt update
sudo apt install jq -y

⸻

STEP 6: Add the Cron Job

Edit your crontab:

crontab -e

Add the following line at the bottom:

*/2 * * * * /full/path/to/CloudFlare_DDNS_Updater.sh >/dev/null 2>&1

Replace /full/path/to with the actual path to your script.

Save and exit. The script will now run every 2 minutes.

⸻

STEP 7: Confirm It Works

Wait a few minutes, then log into Cloudflare and confirm the wildcard A record (*.yourdomain.com) has been updated to your current IP.

If you’d like to keep logs, use this instead:

*/2 * * * * /usr/local/bin/CloudFlare_DDNS_Updater.sh >> /var/log/cloudflare-ddns.log 2>&1

To check the log:

tail -f /var/log/cloudflare-ddns.log

⸻

NOTES:
	•	This script only updates existing wildcard A records (like *.yourdomain.com).
	•	It will not touch the root domain (@) or other records (MX, TXT, CNAME).
	•	TTL is set to 120 seconds (the shortest allowed by Cloudflare).
	•	If the IP hasn’t changed, no update is sent.
	•	If the record does not exist, it is skipped (the script does not create new DNS records).

⸻

TROUBLESHOOTING:
	•	If the script always says it’s updating even when the IP is unchanged, check for jq errors or misconfigured zone/record names.
	•	Use bash -x CloudFlare_DDNS_Updater.sh to debug step-by-step.
	•	Check your token permissions and make sure the DNS records exist ahead of time.
